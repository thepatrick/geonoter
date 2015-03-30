//
//  PQGAppDelegate.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 13/06/13.
//  Copyright (c) 2013 Patrick Quinn-Graham. All rights reserved.
//

#import "PQGAppDelegate.h"
#import "GeoNoter-Swift.h"
#import "Foursquare2.h"
#import "GeoNoterCore.h"

@implementation PQGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{  
  [[NSUserDefaults standardUserDefaults] registerDefaults:@{
    @"LocationsUseGeocoder": @(YES),
    @"LocationsDefaultName": @"most-specific"
  }];
  
  // Add the tab bar controller's current view as a subview of the window
  
  self.window.backgroundColor = [UIColor whiteColor];
  
  self.store = [[PQGPersistStore alloc] initWithFile:[PQGPersistStore URLForDocument:@"geonoter.db"]];
  
  NSError *error = [[LocationHelper sharedHelper] requestIfNotYetDone];
  if(error) {
    NSLog(@"error! %@", error);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:error.localizedDescription message:@"You will not be able to add points at this time" preferredStyle:UIAlertControllerStyleAlert];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
  } else {
    [[[CLLocationManager alloc] init] requestWhenInUseAuthorization];
  }
  
  
  [Foursquare2 setupFoursquareWithClientId:@"QDD4H5DPDAQZBCMDPY2ZCKIW01WLVSO44NKVSDIYD3ULA10R"
                                    secret:@"5AE4ZA1RGY0PQ15ADS51UFRF4MNYGJSRMGUUW2XZZ1O3LEVZ"
                               callbackURL:@"x-com-pftqg-geonoter"];
  
  
  return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply
{
  NSLog(@"handleWatchKitExtensionRequest:%@", userInfo);
  UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithName:@"handleWatchKitExtensionRequest" expirationHandler:^{
    NSLog(@"WatchKit task timed out");
  }];
  NSString *watchWants = userInfo[@"watchWants"];
  
  if([watchWants isEqualToString:@"nearbyPlaces"]) {
        
    PQGFoursquareHelper *foursquareHelper = [[PQGFoursquareHelper alloc] init];
    
    NSNumber *lat = userInfo[@"location"][@"lat"];
    NSNumber *lng = userInfo[@"location"][@"lng"];
        
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
    
    [foursquareHelper venuesForCoordinates:coordinates completion:^(NSArray *places, NSError *error) {
      if (error) {
        reply(@{ @"error": error.localizedDescription });
      } else {
      reply(@{ @"nearbyPlaces": places });
        [application endBackgroundTask:bgTask];
      }
    }];
    
  } else if ([watchWants isEqualToString:@"addFoursquareVenue"]) {
        
    PQGPoint *point = [[PQGPoint alloc] initWithStore:self.store];

    NSLog(@"addFoursquareVenue =>");
    
    [point setupFromFoursquareVenue:userInfo[@"venue"]];

    NSLog(@"addFoursquareVenue <=");

    
    if (userInfo[@"memo"]) {
      NSLog(@"adding memo %@", userInfo[@"memo"]);
      [self.store setMemoForWatch:point.primaryKey memo:userInfo[@"memo"]];
    } else {
      NSLog(@"No memo!");
    }
      
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addedPoint" object:self userInfo:@{ @"point": point  }];
        
    reply(@{ @"pointId": @(point.primaryKey) });
    [application endBackgroundTask:bgTask];
    
  } else if ([watchWants isEqualToString:@"tags"]) {
    
    reply(@{ @"tags": [self.store allTagsForWatch] });
    [application endBackgroundTask:bgTask];
  
  } else if ([watchWants isEqualToString:@"tagPoints"] && userInfo[@"tagId"] != nil) {
    
    NSNumber *tagId = userInfo[@"tagId"];
    reply(@{ @"points": [self.store allPointsInTagForWatch:tagId.longLongValue] });
    [application endBackgroundTask:bgTask];
  
  } else if ([watchWants isEqualToString:@"recent"]) {
    
    reply(@{ @"points": self.store.recentPointsForWatch });
    [application endBackgroundTask:bgTask];
    
  } else {
    reply(@{ @"error": @"unsupported request" });
    [application endBackgroundTask:bgTask];
  }
}

@end
