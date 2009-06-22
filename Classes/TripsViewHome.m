//
//  TripsViewHome.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import "Trip.h"
#import "TripsViewHome.h"
#import "GeoNoterAppDelegate.h"
#import "PersistStore.h"


@implementation TripsViewHome

@synthesize tripsTable;
@synthesize trips;
@synthesize addTrip;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Trips";
	self.navigationItem.rightBarButtonItem = addTrip;
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	[self reloadData];
	NSLog(@"trips: %@", trips);
}

-(void)reloadData
{
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	self.trips = [del.store getAllTrips];
	[tripsTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[trips release];
    [super dealloc];
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"trip"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"trip"] autorelease];
	}
	
	Trip *trip = [[self.trips objectAtIndex:indexPath.row] hydrate];
	cell.textLabel.text = trip.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
	return cell;
}

-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
	return [self.trips count];
}

@end
