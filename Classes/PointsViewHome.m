//
//  PointsViewHome.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 13/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import "GNPoint.h"
#import "GeoNoterAppDelegate.h"
#import "PersistStore.h"
#import "PointsViewHome.h"
#import "PointsDetail.h"


@implementation PointsViewHome

@synthesize pointsTable;
@synthesize points;
@synthesize addPoint;


- (void)viewDidLoad {
	self.title = @"Locations";
	self.navigationItem.rightBarButtonItem = addPoint;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)viewWillAppear:(BOOL)animated
{
	[self reloadData];
	NSLog(@"points: %@", points);
}

-(void)reloadData
{
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	self.points = [del.store getAllPoints];
	[pointsTable reloadData];
}

- (void)dealloc {
	[points release];
    [super dealloc];
}

#pragma mark -
#pragma mark TableView Delegate/DataSource Methods

-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"point"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"point"] autorelease];
	}
	
	GNPoint *point = [[self.points objectAtIndex:indexPath.row] hydrate];
	cell.text = point.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
	return [self.points count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	GNPoint *p = [self.points objectAtIndex:indexPath.row];
	PointsDetail *pd = [PointsDetail pointsDetailWithPoint:p andStore:del.store];
	[self.navigationController pushViewController:pd animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Other UI Actions

-(IBAction)addPoint:(id)sender {
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];

	GNPoint *point = [GNPoint point];
	point.name = @"New point!";
	point.latitude = del.latitude;
	point.longitude = del.longitude;
	point.friendlyName = @"Friendly name not implemented yet";
	point.memo = @"No memo";
	point.recordedAt = [NSDate date];
	
	[del.store insertOrUpdatePoint:point];
	[self reloadData];
}

@end
