//
//  SettingsViewContainer.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 10-05-22.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface SettingsViewContainer : UINavigationController {
	Settings *settingsView;	
}

@property (nonatomic, retain) Settings *settingsView;

@end
