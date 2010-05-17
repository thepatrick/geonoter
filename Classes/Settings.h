//
//  Settings.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 15/02/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface Settings : UIViewController<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {

	IBOutlet UITableView *tableView;
	
	NSArray *settingsGroups;
	NSArray *settingsOptions;
	
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

-(void)prepareDebugCell:(UITableViewCell*)cell atRow:(NSInteger)row;
-(void)didSelectDebugRow:(NSInteger)row;
@end
