//
//  GeoNoterAppDelegate.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/01/09.
//  Copyright Bunkerworld Publishing Ltd. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class PersistStore;

@interface GeoNoterAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	
	PersistStore *store;
	
	CLLocationManager *locationManager;
	float longitude;
	float latitude;
	BOOL background;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) PersistStore *store;

@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) float latitude;


- (NSString*)getDocumentPath:(NSString*)path;
- (NSString*)attachmentsDirectory;
- (void)startUpdates;
-(void)launchMailAppOnDevice;

@end
