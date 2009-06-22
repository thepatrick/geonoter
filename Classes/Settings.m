//
//  Settings.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 15/02/09.
//  Copyright 2009 Petromedia Ltd.. All rights reserved.
//

#import "Settings.h"


@implementation Settings

@synthesize tableView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	settingsGroups = [[NSArray arrayWithObjects:@"About", nil] retain];
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
	return [settingsGroups count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [settingsGroups objectAtIndex:section];
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"aboutInfo"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"aboutInfo"] autorelease];
	}
	cell.textLabel.text = @"Version 1.0";
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
	return 1;
}


@end
