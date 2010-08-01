//
//  GeoNoterAppDelegate.m
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 11/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "GeoNoterAppDelegate.h"
#import "PersistStore.h"
#import "GNPoint.h"
#import "Settings.h"


@implementation GeoNoterAppDelegate

@synthesize window, tabBarController;
@synthesize store, longitude, latitude;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithCapacity:1];
	
	[Settings registerDefaultsInDictionary:defaults];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	
    // Add the tab bar controller's current view as a subview of the window
	
	self.store = [PersistStore storeWithFile:[self getDocumentPath:@"geonoter.db"]];
	
    [window addSubview:tabBarController.view];
	
	[self startUpdates];
	background = NO;
}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

#pragma mark -
#pragma mark Filesystem stuff

// Creates a writable copy of the bundled default database in the application Documents directory.
- (NSString*)getDocumentPath:(NSString*)path {
    // First, test for existence.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
#pragma mark Begin Workaround: create application "Documents" directory if needed
    // Workaround for Beta issue where Documents directory is not created during install.
    BOOL exists = [fileManager fileExistsAtPath:documentsDirectory];
    if (!exists) {
		NSError *err;
        BOOL success = [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&err];
        if (!success) {
            NSAssert(0, @"Failed to create Documents directory.");
        }
    }
#pragma mark End Workaround
	
	return [documentsDirectory stringByAppendingPathComponent:path];
}

-(NSString*)attachmentsDirectory {

	NSString *dir = [self getDocumentPath:@"Attachments"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];

	BOOL isDirectory;
	if(![fileManager fileExistsAtPath:dir isDirectory:&isDirectory]) {
		NSError *err;
        BOOL success = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
		
        if (!success) {
            NSAssert(0, @"Failed to create Attachments directory.");
        }
	}
	
	return dir;
}

#pragma mark -
#pragma mark CoreLocation interface

- (void)startUpdates {
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
	
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest  ;
	
    // Set a movement threshold for new events
    locationManager.distanceFilter = 1;
	
    [locationManager startUpdatingLocation];
}


// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 5.0) {
		latitude = newLocation.coordinate.latitude;
		longitude = newLocation.coordinate.longitude;
        DLog(@"latitude %+.6f, longitude %+.6f\n", latitude, longitude);
    }
}

#pragma mark -
#pragma mark Multitasking callbacks

- (void)applicationDidEnterBackground:(UIApplication *)application {
	background = YES;
	//[locationManager startMonitoringSignificantLocationChanges];//
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	background = NO;
//	[locationManager stopUpdatingLocation];
//	[locationManager startUpdatingLocation];
}

#pragma mark -
#pragma mark Misc utils

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice {
    NSString *recipients = @"mailto:";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:recipients]];
}

@end

