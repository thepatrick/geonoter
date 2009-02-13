//
//  FirstViewController.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/01/09.
//  Copyright Bunkerworld Publishing Ltd. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TripsViewHome;

@interface TripsViewController : UINavigationController {
	TripsViewHome *homeView;
}
@property (nonatomic, retain) TripsViewHome *homeView;

@end