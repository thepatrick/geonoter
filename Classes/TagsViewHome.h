//
//  TagsViewHome.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 12/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TagsViewHome : UIViewController<UITableViewDelegate, UITableViewDataSource> {

	IBOutlet UITableView *tagsTable;
	IBOutlet UIBarButtonItem *addTag;
	
	NSArray *tags;
	
}

@property (nonatomic, retain) IBOutlet UITableView *tagsTable;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addTag;
@property (nonatomic, retain) NSArray *tags;

-(void)reloadData;

@end
