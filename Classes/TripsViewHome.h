//
//  TripsViewHome.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TripsViewHome : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	
	IBOutlet UITableView *tripsTable;
	IBOutlet UIBarButtonItem *addTrip;
	
	NSArray *trips;
	
}

@property (nonatomic, retain) IBOutlet UITableView *tripsTable;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addTrip;
@property (nonatomic, retain) NSArray *trips;

-(void)reloadData;

@end
