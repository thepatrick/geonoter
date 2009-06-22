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
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];

	GNPoint *point = [GNPoint point];
	point.latitude = del.latitude;
	point.longitude = del.longitude;
	point.recordedAt = [NSDate date];

	[self showLoading];
	[self populateNewPointV2:point];
	//[self performSelectorInBackground:@selector(populateNewPoint:) withObject:point];
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

-(void)populateNewPointV2:(GNPoint*)point {
	CLLocationCoordinate2D coords;
	coords.latitude = point.latitude;
	coords.longitude = point.longitude;
	
	MKReverseGeocoder *geo = [[MKReverseGeocoder alloc] initWithCoordinate:coords];
	geo.delegate = self;
	pointAwaitingGeocoding = point;
	[pointAwaitingGeocoding retain];
	[geo start];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	NSLog(@"Failed to reverse geocode ... error %@", error);
	pointAwaitingGeocoding.friendlyName = @"Geocoder Unavailable";
	[self newPointComplete:pointAwaitingGeocoding]; 
	[pointAwaitingGeocoding release];
	pointAwaitingGeocoding = nil;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	NSLog(@"Did find placemark! %@", placemark);
	
	
	NSString *base = placemark.country;
	NSString *simpleName = placemark.country;
	
	
	if(placemark.administrativeArea && ![placemark.administrativeArea isEqualToString:@""]) {
		base = [placemark.administrativeArea stringByAppendingFormat:@", %@", base];
		simpleName = placemark.administrativeArea;
	}
	
	if(placemark.locality && ![placemark.locality isEqualToString:@""]) {
		base = [placemark.locality stringByAppendingFormat:@", %@", base];
		simpleName = placemark.locality;
	}
	
	if(placemark.subLocality && ![placemark.subLocality isEqualToString:@""]) {
		base = [placemark.subLocality stringByAppendingFormat:@", %@", base];
		simpleName = placemark.subLocality;
	}
	
	
	if(placemark.thoroughfare && ![placemark.thoroughfare isEqualToString:@""]) {
		base = [placemark.thoroughfare stringByAppendingFormat:@", %@", base];
		if(!placemark.subLocality || [placemark.subLocality isEqualToString:@""]) {
			simpleName = placemark.thoroughfare;
		}
	}
	
	
	if(placemark.subThoroughfare && ![placemark.subThoroughfare isEqualToString:@""]) {
		base = [placemark.subThoroughfare stringByAppendingFormat:@" %@", base];
		if(!placemark.subLocality || [placemark.subLocality isEqualToString:@""]) {
			simpleName = [placemark.subThoroughfare stringByAppendingFormat:@" %@", placemark.thoroughfare];
		}
	}
	
	pointAwaitingGeocoding.name = simpleName;
	pointAwaitingGeocoding.friendlyName = base;

	[self newPointComplete:pointAwaitingGeocoding];
	[pointAwaitingGeocoding release];
	pointAwaitingGeocoding = nil;
}

// This version uses the geonames.org webservice. It's not as accurate as the MKReverseGeocoder 
// version (or at least Google provides more information down to street level in Canada).
// Keeping for noew for historical purposes.
-(void)populateNewPoint:(GNPoint*)point {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *url = [NSString stringWithFormat:@"http://ws.geonames.org/findNearbyPlaceNameJSON?lat=%f&lng=%f",
											   point.latitude, point.longitude];
	
	NSError *err = nil;
	NSString *data = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] 
											  encoding:NSStringEncodingConversionExternalRepresentation 
                                                 error:&err];
	
	if(err) {
		//um, fudge 
		point.name = @"New location";
		point.friendlyName = @"Geocoder Unavailable";
		DLog(@"error was %@", [err localizedDescription]);
	} else {
		NSDictionary *dataDict =  [data JSONValue];
		NSArray *places = [dataDict objectForKey:@"geonames"];
		
		if([places count] == 0) {
			DLog(@"dataDict was %@", dataDict);
			point.name = @"New location";
			point.friendlyName = @"Geocoder Unavailable";
			
		} else {
		
			NSDictionary *place = [places objectAtIndex:0];
			
			NSString *placeName = [place objectForKey:@"name"];
			NSString *placeState = [place objectForKey:@"adminName1"];
			NSString *placeCountry = [place objectForKey:@"countryCode"];
			
			if(placeState != nil && ![placeState isEqualToString:@""]) {
				placeName = [placeName stringByAppendingFormat:@", %@", placeState];
			}
			if(placeCountry != nil && ![placeCountry isEqualToString:@""]) {
				placeName = [placeName stringByAppendingFormat:@", %@", placeCountry];
			}
			
			point.friendlyName = placeName;
			point.name = placeName;
			
		}

	}


	[self performSelectorOnMainThread:@selector(newPointComplete:) 
						   withObject:point
						waitUntilDone:YES];
	[pool release];
}

-(void)newPointComplete:(GNPoint*)point {
	point.memo = @"No memo";	
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	[del.store insertOrUpdatePoint:point];
	[self reloadData];	
	self.navigationItem.rightBarButtonItem = addPoint;
}

@end
