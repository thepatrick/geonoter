//
//  PointsViewController.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 13/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PointsViewHome;

@interface PointsViewController : UINavigationController {
	PointsViewHome *homeView;
}
@property (nonatomic, retain) PointsViewHome *homeView;


@end
