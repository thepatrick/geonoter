//
//  Point.m
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 12/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "SQLDatabase.h"
#import "PersistStore.h"
#import "GNPoint.h"
#import "Tag.h"
#import "GeoNoterAppDelegate.h"
#import "Settings.h"

@implementation GNPoint

@synthesize dbId;
@synthesize tripId;
@synthesize friendlyName;
@synthesize name;
@synthesize memo;
@synthesize recordedAt;
@synthesize latitude;
@synthesize longitude;
@synthesize store;

+point
{
	return [[[self alloc] init] autorelease];
}

+pointWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore
{
	return [[[self alloc] initWithPrimaryKey:theID andStore:newStore] autorelease];
}

-init
{
	if(self = [super init]) {
		dirty = NO;
		hydrated = NO;
	}
	return self;
}

-initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore
{
	if(self = [super init]) {
		dbId = [[NSNumber numberWithInteger:theID] retain];
		store = [newStore retain];
		hydrated = NO;
		dirty = NO;
	}
	return self;
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@> ID: '%@'. Name: '%@'.", [self class], self.dbId, self.name];
}

-hydrate
{
	if(self.dbId == nil || hydrated) {
		return self; // we're not going to hydrate in this situation, it's unncessary!
	}
	
	SQLResult *res = [store.db performQueryWithFormat:@"SELECT * FROM point WHERE id = %d", [self.dbId integerValue]];
	if([res rowCount] == 0) {
		NSLog(@"Didn't hydrate because the select returned 0 results, sql was %@", [NSString stringWithFormat:@"SELECT * FROM point WHERE id = %@", self.dbId]);
		return self; // bugger.
	}
	
	SQLRow *row = [res rowAtIndex:0];
	
	self.tripId = [[row stringForColumn:@"name"] integerValue];
	self.friendlyName = [row stringForColumn:@"friendly_name"];
	self.name = [row stringForColumn:@"name"];
	self.memo = [row stringForColumn:@"memo"];	
	self.recordedAt = [row dateForColumn:@"recorded_at"];
	self.latitude = [[row stringForColumn:@"latitude"] floatValue];
	self.longitude = [[row stringForColumn:@"longitude"] floatValue];
	
	hydrated = YES;
	return self;
}

-(void)dehydrate
{
	if(!hydrated) return; // no point wasting time
	
	if(self.dbId == nil) {
		return; // we're not going to dehydrate in this situation, it's unpossible!
	}
	
	[self save];
	
	[friendlyName release];
	friendlyName = nil;
	[name release];
	name = nil;
	[memo release];
	memo = nil;
	[recordedAt release];
	recordedAt = nil;
	
	hydrated = NO;
}

-(void)save
{
	if(dirty) {
		[store insertOrUpdatePoint:self];
		dirty = NO;
	}	
}


-(void)setTripId:(NSInteger)newValue
{
	tripId = newValue;
	dirty = YES;	
}

-(void)setFriendlyName:(NSString*)newValue
{
	[friendlyName release];
	friendlyName = [newValue copy];
	dirty = YES;	
}

-(void)setName:(NSString*)newValue
{
	[name release];
	name = [newValue copy];
	dirty = YES;	
}

-(void)setMemo:(NSString*)newValue
{
	[memo release];
	memo = [newValue copy];
	dirty = YES;	
}

-(void)setRecordedAt:(NSDate*)newValue
{
	[recordedAt release];
	recordedAt = [newValue copy];
	dirty = YES;	
}

-(void)setLatitude:(CGFloat)newValue
{
	latitude = newValue;
	dirty = YES;	
}

-(void)setLongitude:(CGFloat)newValue
{
	longitude = newValue;
	dirty = YES;	
}

-(NSArray*)tags {
	NSString *cond = [NSString stringWithFormat:@"id IN (select tag_id FROM point_tag WHERE point_id = %@)", self.dbId];
	return [store getTagsWithConditions:cond andSort:@"name ASC"];
}


-(void)setTags:(NSArray*)newTags {
	DLog(@"Removing existing tags...");
	[store removeTagFromPoint:[self.dbId integerValue]];
	for(Tag *t in newTags) {
		DLog(@"Adding tag tag... %@", t);
		DLog(@"Using store %@", store);
		[store addTag:[t.dbId integerValue] toPoint:[self.dbId integerValue]];
	}
}


-(NSArray*)attachments {
	NSString *cond = [NSString stringWithFormat:@"point_id = %d", [self.dbId integerValue]];
	return [store getAttachmentsWithConditions:cond andSort:@"recorded_at ASC"];
}

-(GNPoint*)storePointData {
	GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	self.latitude = del.latitude;
	self.longitude = del.longitude;
	self.recordedAt = [NSDate date];
	self.name = @"Untitled";
	self.friendlyName = @"Untitled";
	self.memo = @"No memo";
	return self;
}

-(void)determineDefaultName:(NSString*)locationName {
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:GNLocationsDefaultsDefaultName] isEqualToString:GNLocationsDefaultNameMostSpecific] && locationName != nil) {
		self.name = locationName;
	} else if([[[NSUserDefaults standardUserDefaults] stringForKey:GNLocationsDefaultsDefaultName] isEqualToString:GNLocationsDefaultNameCoordinates]) {
		self.name = [NSString stringWithFormat:@"%f, %f", self.longitude, self.latitude];
	} else {
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		self.name = [dateFormatter stringFromDate:[NSDate date]];			
	}
	
}

#pragma mark -
#pragma mark Geocoder



-(void)geocoderFinishedCleanup {
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self->bgTask != UIBackgroundTaskInvalid) {
			self->populateDelegate = nil;
			[[UIApplication sharedApplication] endBackgroundTask:self->bgTask];
			self->bgTask = UIBackgroundTaskInvalid;
			Block_release(completionCallback);
		}
	});
}

-(void)geocodeWithCompletionBlock:(void (^)())completion {
	[self storePointData];
	completionCallback = Block_copy(completion);
	
	CLLocationCoordinate2D coords;
	coords.latitude = self.latitude;
	coords.longitude = self.longitude;
	
	UIApplication *app = [UIApplication sharedApplication];
	NSAssert(self->bgTask == UIBackgroundTaskInvalid, nil);
	
	MKReverseGeocoder *geo = [[MKReverseGeocoder alloc] initWithCoordinate:coords];
	geo.delegate = self;
	self->bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
		[geo cancel];
		self.friendlyName = @"Geocoder Unavailable";
		if(completionCallback != nil) completionCallback();
		[self geocoderFinishedCleanup];
		[geo release];
	}];
	[geo start];
}

#pragma mark -
#pragma mark Geocoder Delegate methods

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	NSLog(@"Failed to reverse geocode ... error %@", error);
	self.friendlyName = @"Geocoder Unavailable";
	if(completionCallback != nil) completionCallback();
	[geocoder release];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	DLog(@"Did find placemark! %@", placemark);
	
	NSString *simpleName = placemark.country;
//	NSArray *address = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"];

	NSMutableString *addressFormatted = [NSMutableString stringWithString:@""];
	for(NSString *fragment in [placemark.addressDictionary valueForKey:@"FormattedAddressLines"]) {
		if(![addressFormatted isEqualToString:@""]) {
			[addressFormatted appendString:@", "];
		}
		[addressFormatted appendString:fragment];
	}
	
	if(placemark.administrativeArea && ![placemark.administrativeArea isEqualToString:@""]) {
		simpleName = placemark.administrativeArea;
	}
	if(placemark.locality && ![placemark.locality isEqualToString:@""]) {
		simpleName = placemark.locality;
	}
	if(placemark.subLocality && ![placemark.subLocality isEqualToString:@""]) {
		simpleName = placemark.subLocality;
	}
	if(placemark.thoroughfare && ![placemark.thoroughfare isEqualToString:@""]) {
		if(!placemark.subLocality || [placemark.subLocality isEqualToString:@""]) {
			simpleName = placemark.thoroughfare;
		}
	}
	if(placemark.subThoroughfare && ![placemark.subThoroughfare isEqualToString:@""]) {
		if(!placemark.subLocality || [placemark.subLocality isEqualToString:@""]) {
			simpleName = [placemark.subThoroughfare stringByAppendingFormat:@" %@", placemark.thoroughfare];
		}
	}
	
	[self determineDefaultName:simpleName];
	self.friendlyName = addressFormatted;

	if(completionCallback != nil) completionCallback();
	[self geocoderFinishedCleanup];
	[geocoder release];
}



@end
