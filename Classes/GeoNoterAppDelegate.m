//
//  GeoNoterAppDelegate.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/01/09.
//  Copyright Bunkerworld Publishing Ltd. 2009. All rights reserved.
//

#import "GeoNoterAppDelegate.h"
#import "PersistStore.h"


@implementation GeoNoterAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize store;

@synthesize longitude;
@synthesize latitude;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Add the tab bar controller's current view as a subview of the window
	
	self.store = [PersistStore storeWithFile:[self getDocumentPath:@"geonoter.db"]];
	
    [window addSubview:tabBarController.view];
	
	[self startUpdates];
}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (NSString*)getDocumentPath:(NSString*)path
{
    // First, test for existence.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
#pragma mark Begin Workaround: create application "Documents" directory if needed
    // Workaround for Beta issue where Documents directory is not created during install.
    BOOL exists = [fileManager fileExistsAtPath:documentsDirectory];
    if (!exists) {
        BOOL success = [fileManager createDirectoryAtPath:documentsDirectory attributes:nil];
        if (!success) {
            NSAssert(0, @"Failed to create Documents directory.");
        }
    }
#pragma mark End Workaround
	
	return [documentsDirectory stringByAppendingPathComponent:path];
}


- (void)startUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
	
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	
    // Set a movement threshold for new events
    locationManager.distanceFilter = 1;
	
    [locationManager startUpdatingLocation];
}


// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 5.0)
    {
		//        [manager stopUpdatingLocation];
		
		latitude = newLocation.coordinate.latitude;
		longitude = newLocation.coordinate.longitude;
				
        printf("latitude %+.6f, longitude %+.6f\n", latitude, longitude);
		
    }
}

@end

