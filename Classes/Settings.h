//
//  Settings.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 15/02/09.
//  Copyright 2009 Petromedia Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Settings : UIViewController<UITableViewDelegate, UITableViewDataSource> {

	IBOutlet UITableView *tableView;
	
	NSArray *settingsGroups;
	
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
