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
#import "JSON.h"


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
	DLog(@"points: %@", points);
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
	cell.textLabel.text = point.name;
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
	GNPoint *point = [[GNPoint point] retain];
	[self showLoading];
	[point populateNewPoint:self];
}

-(void)showLoading {
	// initing the loading view
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[loading startAnimating];
	[loading sizeToFit];
	loading.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
								UIViewAutoresizingFlexibleRightMargin |
								UIViewAutoresizingFlexibleTopMargin |
								UIViewAutoresizingFlexibleBottomMargin);
	
	// initing the bar button
	UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:loading];
	
	loadingView.style = UIBarButtonItemStyleBordered;
	[loading release];
	loadingView.target = self;
	
	self.navigationItem.rightBarButtonItem = loadingView;
	
}

-(void)newPointComplete:(GNPoint*)point {
	point.memo = @"No memo";	
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	[del.store insertOrUpdatePoint:point];
	[self reloadData];	
	self.navigationItem.rightBarButtonItem = addPoint;
	[point release];
}

@end
