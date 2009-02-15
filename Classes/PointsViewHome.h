//
//  PointsViewHome.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 13/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PointsViewHome : UIViewController<UITableViewDelegate, UITableViewDataSource> {

	IBOutlet UITableView *pointsTable;
	IBOutlet UIBarButtonItem *addPoint;
	
	NSArray *points;
	
}


@property (nonatomic, retain) IBOutlet UITableView *pointsTable;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addPoint;
@property (nonatomic, retain) NSArray *points;

-(void)reloadData;
-(IBAction)addPoint:(id)sender;
-(void)showLoading;

@end
