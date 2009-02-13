//
//  PointsDetail.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 14/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import "MapViewCell.h"
#import "PersistStore.h"
#import "GNPoint.h"
#import "Tag.h"
#import "PointsDetail.h"

#define PointsDetailSectionMap 0
#define PointsDetailSectionDetails 1
#define PointsDetailSectionTags 2
#define PointsDetailSectionAttachments 3

@implementation PointsDetail

@synthesize locationName;
@synthesize detailTable;
@synthesize point;
@synthesize store;
@synthesize actionButton;

+pointsDetailWithPoint:(GNPoint*)newPoint andStore:(PersistStore*)newStore
{
	PointsDetail *newDetail = [[[self alloc] initWithNibName:@"PointsDetailView" bundle:nil] autorelease];
	newDetail.store = newStore;
	newDetail.point = newPoint;
	return newDetail;
}

- (void)viewDidLoad {
	self.title = @"Location";
	
	self.navigationItem.rightBarButtonItem = self.actionButton;
	sectionNames = [[NSArray arrayWithObjects:@"Map", @"Details", @"Tags", @"Attachments", nil] retain];
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void)viewWillAppear:(BOOL)animated
{
	//[self reloadData];
	NSLog(@"points: %@", point);
	[point hydrate];
	self.locationName.text = point.name;
}

- (void)dealloc {
	[point release];
	[store release];
	[detailTable release];
	[locationName release];
	[sectionNames release];
	[pointActions release];
    [super dealloc];
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForMapRow:(NSInteger)row {
	MapViewCell *movieCell = (MapViewCell *)[tv dequeueReusableCellWithIdentifier:@"map"];
	if(!movieCell) {
		movieCell = [[[MapViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"map"] autorelease];
	}
	return movieCell;
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForDetailsRow:(NSInteger)row {
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"detailsRow"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"detailsRow"] autorelease];
	}
	
	cell.textColor = [UIColor blackColor];

	
	DLog(@"hello from cellForDetailsRow!");
	NSDateFormatter *dateFormatter;
	switch (row) {
		case 0:
			cell.text = point.friendlyName;
			break;
		case 1:
			cell.text = point.memo;
			if([point.memo isEqualToString:@"No memo"]) {
				cell.textColor = [UIColor lightGrayColor];				
			}
			break;
		case 2:
			dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
			[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
			cell.text = [dateFormatter stringFromDate:point.recordedAt];
			break;
		case 3:
			cell.text = [NSString stringWithFormat:@"%f, %f", point.longitude, point.latitude];
	}
	
	//cell.text = point.name;
	
	return cell;
	
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForTagsRow:(NSInteger)row {
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"detailsRow"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"detailsRow"] autorelease];
	}
	
	NSArray *tags = [point tags];
	Tag *tag = [[tags objectAtIndex:row] hydrate];
	cell.text = tag.name;
	//cell.text = point.name;
	
	return cell;
	
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell *cell;
	
	switch (indexPath.section) {
		case PointsDetailSectionMap: 
			return [self tableView:tv cellForMapRow:indexPath.row];
		
		case PointsDetailSectionDetails: // details
			return [self tableView:tv cellForDetailsRow:indexPath.row];
			
		case PointsDetailSectionTags: // tags
			return [self tableView:tv cellForTagsRow:indexPath.row];
			
		case PointsDetailSectionAttachments: // attachments
		default:
			
			cell = [tv dequeueReusableCellWithIdentifier:@"point"];
			if(!cell) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"point"] autorelease];
			}
			
			cell.text = point.name;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			return cell;
			
			break;
	}
	return nil;
}

-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case PointsDetailSectionMap: 
			return 0;
			
		case PointsDetailSectionDetails: // details
			return 4;
			
		case PointsDetailSectionTags: // tags
			return [[point tags] count];
			
		case PointsDetailSectionAttachments: // attachments
			return 0;
	}
	return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4; // assumes includes recordings
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [sectionNames objectAtIndex:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 0)
		return 200.0;
	else
		return 46.0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	switch (indexPath.section) {
		case PointsDetailSectionMap: 
			return nil;
			
		case PointsDetailSectionDetails: // details
			return (indexPath.row == 1) ? indexPath : nil;
			
		case PointsDetailSectionTags: // tags
			return indexPath;
			
		case PointsDetailSectionAttachments: // attachments
			return indexPath;
	}
	return nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if(textField == locationName) {
		point.name = textField.text;
		[point save];
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField == locationName) {
		[textField resignFirstResponder];
	}
	return YES;
}

- (IBAction)actionButtonAction:(id)sender {
	
	pointActions = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" 
								 destructiveButtonTitle:@"Delete Point" otherButtonTitles:@"Add Tag", @"Record Sound", @"Take Photo", @"Add Existing Photo", nil];
	
	[pointActions showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(actionSheet = pointActions) {
		NSLog(@"Clicked button %d", buttonIndex);
		
		// 0 = delete
		// 1 = add tag
		// 2 = add sound
		// 3 = take photo
		// 4 = existing
		// else... cancel
		
	}
}

@end
