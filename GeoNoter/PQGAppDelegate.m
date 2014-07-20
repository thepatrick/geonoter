//
//  PQGAppDelegate.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 13/06/13.
//  Copyright (c) 2013 Patrick Quinn-Graham. All rights reserved.
//

#import "PQGAppDelegate.h"
#import "PersistStore.h"

#import "FCModel.h"

#import "GeoNoter-Swift.h"

@implementation PQGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{  
  [[NSUserDefaults standardUserDefaults] registerDefaults:@{
    @"LocationsUseGeocoder": @(YES),
    @"LocationsDefaultName": @"most-specific"
  }];
  
  // Add the tab bar controller's current view as a subview of the window
  
  self.window.backgroundColor = [UIColor whiteColor];
  
  [PersistStore openDatabase:[PersistStore pathForResource:@"geonoter.db"]];
  
  NSError *error = [[PQGLocationHelper sharedHelper] requestIfNotYetDone];
  if(error) {
    NSLog(@"error! %@", error);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:error.localizedDescription message:@"You will not be able to add points at this time" preferredStyle:UIAlertControllerStyleAlert];
    [self.window.rootViewController presentViewController:alert animated:YES completion:^{
      NSLog(@"presented mate!");
    }];
  } else {
    NSLog(@"MOO %d", [[PQGLocationHelper sharedHelper] status]);
    
    [[[CLLocationManager alloc] init] requestWhenInUseAuthorization];
  }
  
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

@end
