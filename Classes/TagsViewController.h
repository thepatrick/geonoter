//
//  TagsViewController.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 12/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagsViewHome;

@interface TagsViewController : UINavigationController {
	TagsViewHome *homeView;

}
@property (nonatomic, retain) TagsViewHome *homeView;

@end
