//
//  PointsAddTags.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 14/02/09.
//  Copyright 2009 Petromedia Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersistStore;
@class GNPoint;
@class PointsDetail;

@interface PointsAddTags : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {

	IBOutlet UISearchBar *search;
	IBOutlet UITableView *dataTable;
	
	GNPoint *point;
	PersistStore *store;
	
	NSArray *tags;
	NSMutableArray *chosenTags;
	
	PointsDetail *delegate;
}

@property (nonatomic, retain) UISearchBar *search;
@property (nonatomic, retain) UITableView *dataTable;
@property (nonatomic, retain) GNPoint *point;
@property (nonatomic, retain) PersistStore *store;
@property (nonatomic, retain) NSArray *tags;
@property (nonatomic, retain) PointsDetail *delegate;

+pointsAddTagsWithPoint:(GNPoint*)point andStore:(PersistStore*)store;

-(IBAction)cancel;
-(IBAction)done;

@end
