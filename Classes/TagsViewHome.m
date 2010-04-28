//
//  TagsViewHome.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 12/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import "Tag.h"
#import "GeoNoterAppDelegate.h"
#import "PersistStore.h"
#import "TagsViewHome.h"
#import "PointsViewHome.h"

@implementation TagsViewHome


@synthesize tagsTable;
@synthesize tags;
@synthesize cancelAddTag;
@synthesize addTag;

- (PersistStore*)store {
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	return del.store;	
}

- (void)viewDidLoad {
	self.title = @"Tags";
	
	UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
	self.navigationItem.rightBarButtonItem = [edit autorelease];
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void)viewWillAppear:(BOOL)animated
{
	[self reloadData];
	NSLog(@"tags: %@", tags);
}

-(void)reloadData {
	[self fetchData];
	[tagsTable reloadData];
}

-(void)fetchData {
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	self.tags = [del.store getAllTags];
}

- (void)dealloc {
	[tags release];
    [super dealloc];
}

-(void)edit:(id)sender {
	self.tagsTable.editing = !self.tagsTable.editing;
}

#pragma mark -
#pragma mark TableView Delegate/DataSource Methods

-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"tag"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"tag"] autorelease];
	}
	
	Tag *tag = [[self.tags objectAtIndex:indexPath.row] hydrate];
	cell.textLabel.text = tag.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
	return [self.tags count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Tag *tag = [self.tags objectAtIndex:indexPath.row];
	PointsViewHome *pvh = [[[PointsViewHome alloc] initWithNibName:@"PointsViewHome" bundle:nil] autorelease];
	[pvh setDatasourceFetchAll:^() {
		return [tag points];
	}];
	[pvh setDatasourceDidCreateNewPoint:^(GNPoint* point) {
		DLog(@"setDatasourceDidCreateNewPoint!");
		[point setTags:[NSArray arrayWithObject:tag]];
	}];
	[self.navigationController pushViewController:pvh animated:YES];
	pvh.title = tag.name;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(editingStyle != UITableViewCellEditingStyleDelete)
		return;
	Tag *tag = [self.tags objectAtIndex:indexPath.row];
	[tag destroy];
	[self fetchData];
	[tagsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
}

#pragma mark -
#pragma mark Add Text Field Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.navigationItem.rightBarButtonItem = cancelAddTag;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	Tag *t = [Tag tag];
	t.name = textField.text;
	textField.text = @"";

	self.navigationItem.rightBarButtonItem = nil;
	
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	[del.store insertOrUpdateTag:t];
	
	[self reloadData];
	[textField resignFirstResponder];
	return YES;
}

-(IBAction)cancelAddTagNow:(id)sender {
	self.navigationItem.rightBarButtonItem = nil;
	addTag.text = @"";
	[addTag resignFirstResponder];
}

@end
