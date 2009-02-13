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


@implementation TagsViewHome


@synthesize tagsTable;
@synthesize tags;
@synthesize addTag;

- (void)viewDidLoad {
	self.title = @"Tags";
	self.navigationItem.rightBarButtonItem = addTag;
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

-(void)reloadData
{
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	self.tags = [del.store getAllTags];
	[tagsTable reloadData];
}


- (void)dealloc {
	[tags release];
    [super dealloc];
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"tag"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"tag"] autorelease];
	}
	
	Tag *tag = [[self.tags objectAtIndex:indexPath.row] hydrate];
	cell.text = tag.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
	return [self.tags count];
}

@end
