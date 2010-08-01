//
//  Settings.h
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 15/02/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define GNLocationsDefaultsUseGeocoder     @"LocationsUseGeocoder"
#define GNLocationsDefaultsDefaultName     @"LocationsDefaultName"

#define GNLocationsDefaultNameMostSpecific @"most-specific"
#define GNLocationsDefaultNameCoordinates  @"coords"
#define GNLocationsDefaultNameDateTime     @"datetime"

@interface Settings : UIViewController<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {

	IBOutlet UITableView *tableView;
	
	NSArray *settingsGroups;
	NSArray *settingsOptions;
	
	NSArray *arrayOfDefaultNameOptions;
	NSArray *arrayOfDefaultNameValues;
	
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

+(void)registerDefaultsInDictionary:(NSMutableDictionary*)defaults;

-(UITableViewCell*)dequeOrCreateCellStyle:(UITableViewCellStyle)style withIdentifier:(NSString*)identifier;

-(UITableViewCell*)prepareAboutCellAtRow:(NSInteger)row;
-(void)didSelectAboutRow;

-(UITableViewCell*)prepareLocationsCellAtRow:(NSInteger)row;
-(void)didSelectLocationsRow:(NSInteger)row;

-(UITableViewCell*)prepareDebugCellAtRow:(NSInteger)row;
-(void)didSelectDebugRow:(NSInteger)row;
@end
