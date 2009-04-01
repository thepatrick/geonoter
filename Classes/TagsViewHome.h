//
//  TagsViewHome.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 12/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TagsViewHome : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {

	IBOutlet UITableView *tagsTable;
	IBOutlet UIBarButtonItem *cancelAddTag;
	IBOutlet UITextField *addTag;
	
	NSArray *tags;
	
}

@property (nonatomic, retain) IBOutlet UITableView *tagsTable;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelAddTag;
@property (nonatomic, retain) IBOutlet UITextField *addTag;
@property (nonatomic, retain) NSArray *tags;

-(void)reloadData;

-(IBAction)cancelAddTagNow:(id)sender;

@end
