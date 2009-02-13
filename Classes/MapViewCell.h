//
//  MapViewCell.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 14/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapViewCell : UITableViewCell {
	
	UIWebView *mapView;
	
	CGFloat longitude;
	CGFloat latitude; 
	
}

@property (nonatomic, assign) CGFloat longitude; 
@property (nonatomic, assign) CGFloat latitude; 

@end
