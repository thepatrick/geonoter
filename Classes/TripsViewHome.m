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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Trips";
	self.navigationItem.rightBarButtonItem = addTrip;
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
	[self reloadData];
	NSLog(@"trips: %@", trips);
}

-(void)reloadData {
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

#pragma mark -
#pragma mark TableView Delegate/DataSource Methods


-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"trip"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"trip"] autorelease];
	}
	
	Trip *trip = [[self.trips objectAtIndex:indexPath.row] hydrate];
	cell.textLabel.text = trip.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
	return cell;
}

-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section {
	return [self.trips count];
}

#pragma mark -
#pragma mark Other UI Actions

-(IBAction)addTrip:(id)sender {
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	Trip *trip = [Trip trip];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	trip.name = [dateFormatter stringFromDate:[NSDate date]];
	
	[del.store insertOrUpdateTrip:trip];
	
	[self reloadData];
}

@end
