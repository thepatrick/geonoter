//
//  PointsAddTags.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 14/02/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "PointsDetail.h"
#import "PointsAddTags.h"
#import "GNPoint.h"
#import "GeoNoterAppDelegate.h"
#import "PersistStore.h"
#import "Tag.h"


@implementation PointsAddTags

@synthesize search;
@synthesize dataTable;
@synthesize point;
@synthesize store;
@synthesize tags;
@synthesize delegate;

+pointsAddTagsWithPoint:(GNPoint*)point andStore:(PersistStore*)store {
	PointsAddTags *newTags = [[[self alloc] initWithNibName:@"PointsAddTags" bundle:nil] autorelease];
	if(newTags) {
		newTags.point = point;
		newTags.store = store;
	}
	return newTags;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[dataTable release];
	[search release];
    [super dealloc];
}

-(void)reloadData
{
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	self.tags = [del.store getAllTags];
	if(!chosenTags) {
		chosenTags = [[NSMutableArray arrayWithCapacity:[tags count]] retain];
		[chosenTags addObjectsFromArray:[point tags]];
	}	
	[self.dataTable reloadData];
}


-(void)viewWillAppear:(BOOL)animated
{
	[self reloadData];
	NSLog(@"tags: %@", tags);
}


#pragma mark -
#pragma mark View Actions
-(IBAction)cancel {
	[self dismissModalViewControllerAnimated:YES];
}
-(IBAction)done {
	[point setTags:chosenTags];
	[delegate reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table DataSource/Delegates
-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"tag"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"tag"] autorelease];
	}
	
	Tag *tag = [[self.tags objectAtIndex:indexPath.row] hydrate];
	cell.textLabel.text = tag.name;
	
	if([chosenTags containsObject:tag]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone; //UITableViewCellAccessoryCheckmark	
	}
		
	return cell;
}

-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section {
	return [self.tags count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Tag *tag = [[self.tags objectAtIndex:indexPath.row] hydrate];
	if([chosenTags containsObject:tag]) {
		[chosenTags removeObject:tag];
	} else {
		[chosenTags addObject:tag];
	}
	[self reloadData];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
