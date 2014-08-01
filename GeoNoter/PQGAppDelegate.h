//
//  PQGAppDelegate.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 13/06/13.
//  Copyright (c) 2013 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PQGPersistStore;

@interface PQGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) PQGPersistStore *store;


@end
