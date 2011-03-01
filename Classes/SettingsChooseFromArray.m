//
//  SettingsChooseFromArray.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 10-05-22.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "SettingsChooseFromArray.h"


@implementation SettingsChooseFromArray

@synthesize userOptions, userPicked;

+chooserWithArrayOfOptions:(NSArray*)array andPickedIndex:(NSInteger)picked {
	SettingsChooseFromArray *newPicker = [[[self alloc] initWithNibName:@"SettingsChooseFromArray" bundle:nil] autorelease];
	newPicker.userOptions = array;
	newPicker.userPicked = picked;
	return newPicker;
}

-(void)setUserPickedItem:(void (^)(NSInteger,id))block {
	if(userPickedItem) Block_release(userPickedItem);
	if(block != nil) userPickedItem = Block_copy(block);
	else userPickedItem = nil;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [userOptions count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = [userOptions objectAtIndex:indexPath.row];
	cell.accessoryType = (indexPath.row == userPicked) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	userPicked = indexPath.row;
	[self.tableView reloadData];
	
	if(userPickedItem != nil) {
		userPickedItem(indexPath.row, [userOptions objectAtIndex:indexPath.row]);
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

