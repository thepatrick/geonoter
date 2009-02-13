//
//  PointsDetail.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 14/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersistStore;
@class GNPoint;


@interface PointsDetail : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate> {

	IBOutlet UITableView *detailTable;
	IBOutlet UITextField *locationName;
	IBOutlet UIBarButtonItem *actionButton;
	
	GNPoint *point;
	PersistStore *store;
	
	NSArray *sectionNames;
	
	UIActionSheet *pointActions;
	
}

@property (nonatomic, retain) IBOutlet UITableView *detailTable;
@property (nonatomic, retain) IBOutlet UITextField *locationName;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, retain) GNPoint *point;
@property (nonatomic, retain) PersistStore *store;

+pointsDetailWithPoint:(GNPoint*)newPoint andStore:(PersistStore*)newStore;

-(IBAction)actionButtonAction:(id)sender;

@end
