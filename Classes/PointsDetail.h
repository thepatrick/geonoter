//
//  PointsDetail.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 14/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersistStore;
@class GNPoint;


@interface PointsDetail : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {

	IBOutlet UITableView *detailTable;
	IBOutlet UITextField *locationName;
	IBOutlet UIBarButtonItem *actionButton;
	
	GNPoint *point;
	PersistStore *store;
	
	NSArray *sectionNames;
	
	UIActionSheet *pointActions;
	
	NSArray *tagCache;
	NSArray *attachmentCache;
	
	UIAlertView *deleteAlert;
	
}

@property (nonatomic, retain) IBOutlet UITableView *detailTable;
@property (nonatomic, retain) IBOutlet UITextField *locationName;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, retain) GNPoint *point;
@property (nonatomic, retain) PersistStore *store;

+pointsDetailWithPoint:(GNPoint*)newPoint andStore:(PersistStore*)newStore;

-(void)reloadData;
-(IBAction)actionButtonAction:(id)sender;
-(void)actionSheetDeleteMe;
-(void)actionSheetAddTags;
-(void)actionSheetTakePhoto;
-(void)actionSheetPickPhoto;

-(void)displayAttachment:(NSInteger)index;

@end
