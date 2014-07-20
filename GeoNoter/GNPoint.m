//
//  Point.m
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 12/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "NSStringUUID.h"

#import "SQLDatabase.h"
#import "PersistStore.h"
#import "GNPoint.h"
#import "GNAttachment.h"

#import "PQGTag.h"

#import "GeoNoter-Swift.h"

#import <AddressBookUI/AddressBookUI.h>

@implementation GNPoint

+ (instancetype)point
{
	return [[self alloc] init];
}

+ (instancetype)pointWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore
{
	return [[self alloc] initWithPrimaryKey:theID andStore:newStore];
}

- (instancetype)init
{
	if(self = [super init]) {
		dirty = NO;
		hydrated = NO;
	}
	return self;
}

- (instancetype)initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore
{
	if(self = [super init]) {
		self.dbId = [NSNumber numberWithInteger:theID];
		self.store = newStore;
		hydrated = NO;
		dirty = NO;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@> ID: '%@'. Name: '%@'.", [self class], self.dbId, self.name];
}

- (instancetype)hydrate
{
	if(self.dbId == nil || hydrated) {
		return self; // we're not going to hydrate in this situation, it's unncessary!
	}
	
	SQLResult *res = [self.store.db performQueryWithFormat:@"SELECT * FROM point WHERE id = %d", [self.dbId integerValue]];
	if([res rowCount] == 0) {
		NSLog(@"Didn't hydrate because the select returned 0 results, sql was %@", [NSString stringWithFormat:@"SELECT * FROM point WHERE id = %@", self.dbId]);
		return self; // bugger.
	}
	
	SQLRow *row = [res rowAtIndex:0];
	
  _tripId = [row integerForColumn:@"name"];
  _friendlyName = [row stringForColumn:@"friendly_name"];
	_name = [row stringForColumn:@"name"];
	_memo = [row stringForColumn:@"memo"];
	_recordedAt = [row dateForColumn:@"recorded_at"];
	_latitude = [[row stringForColumn:@"latitude"] doubleValue];
	_longitude = [[row stringForColumn:@"longitude"] doubleValue];
	
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
	
	_friendlyName = nil;
	_name = nil;
	_memo = nil;
	_recordedAt = nil;
	
	hydrated = NO;
}

-(void)save
{
	if(dirty) {
		[self.store insertOrUpdatePoint:self];
		dirty = NO;
	}	
}


-(void)setTripId:(NSInteger)newValue
{
	_tripId = newValue;
	dirty = YES;	
}

-(void)setFriendlyName:(NSString*)newValue
{
	_friendlyName = [newValue copy];
	dirty = YES;	
}

-(void)setName:(NSString*)newValue
{
	_name = [newValue copy];
	dirty = YES;	
}

-(void)setMemo:(NSString*)newValue
{
	_memo = [newValue copy];
	dirty = YES;	
}

-(void)setRecordedAt:(NSDate*)newValue
{
	_recordedAt = [newValue copy];
	dirty = YES;	
}

-(void)setLatitude:(CLLocationDegrees)newValue
{
	_latitude = newValue;
	dirty = YES;	
}

-(void)setLongitude:(CLLocationDegrees)newValue
{
	_longitude = newValue;
	dirty = YES;	
}

#pragma mark - Tags

-(NSArray*)tags {
	NSString *cond = [NSString stringWithFormat:@"id IN (select tag_id FROM point_tag WHERE point_id = %@)", self.dbId];
	return [self.store getTagsWithConditions:cond andSort:@"name ASC"];
}

-(void)addTag:(PQGTag*)tag {
  DLog(@"Adding new tag... %lld", tag.id);
  [self.store addTag:tag.id toPoint:self.dbId.integerValue];
}

-(void)removeTag:(PQGTag*)tag {
  DLog(@"Removing exist tag... %lld", tag.id);
  [self.store removeTag:tag.id fromPoint:self.dbId.integerValue];
}

-(void)setTags:(NSArray*)newTags {
	DLog(@"Removing existing tags...");
	[self.store removeTagsFromPoint:[self.dbId integerValue]];
	for(PQGTag *t in newTags) {
		DLog(@"Adding tag tag... %@", t);
    [self addTag:t];
	}
}

#pragma mark - Defaults

-(void)determineDefaultName:(NSString*)locationName {
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"LocationsDefaultName"] isEqualToString:@"most-specific"] && locationName != nil) {
    NSLog(@"Use location name... %@", locationName);
		self.name = locationName;
	} else if([[[NSUserDefaults standardUserDefaults] stringForKey:@"LocationsDefaultName"] isEqualToString:@"coords"]) {
    self.name = [NSString stringWithFormat:@"%f, %f", self.longitude, self.latitude];
    NSLog(@"Use lat/long name... %@", self.name);
	} else {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    self.name = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"Use date/time name... %@", self.name);
	}
	
}

#pragma mark - Attachments

-(NSArray*)attachments {
  NSString *cond = [NSString stringWithFormat:@"point_id = %ld", [self.dbId longValue]];
  return [self.store getAttachmentsWithConditions:cond andSort:@"recorded_at ASC"];
}


- (GNAttachment*)addAttachment:(NSData*)attachment withExtension:(NSString*)extension {
//  let image = info[UIImagePickerControllerOriginalImage] as UIImage
//  let data = UIImageJPEGRepresentation(image, 1.0)
  
  NSString *fileName = [[NSString stringWithUUID] stringByAppendingPathExtension:extension];
  NSString *actualFile = [[PersistStore attachmentsDirectory] stringByAppendingPathComponent:fileName];
  
  [attachment writeToFile:actualFile atomically:YES];

  GNAttachment *newAttachment = [GNAttachment attachment];
  newAttachment.store = self.store;
  newAttachment.fileName = fileName;
  newAttachment.kind = extension;
  newAttachment.pointId = self.dbId.integerValue;
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateStyle = NSDateFormatterMediumStyle;
  dateFormatter.timeStyle = NSDateFormatterMediumStyle;
  
  NSDate *today = [NSDate date];
  
  newAttachment.friendlyName = [@"Picture - " stringByAppendingString:[dateFormatter stringFromDate:today]];
  newAttachment.memo = @"No memo";
  newAttachment.recordedAt = today;
  [newAttachment save];

  return newAttachment;
}


#pragma mark - Geocode (maybe)

- (void)setupAsNewItem:(void (^)())completionHandler {
  
  PQGLocationHelper *helper = [PQGLocationHelper sharedHelper];
  
  [helper location:^(CLLocation *location, NSError *error) {
    if(error) {
      NSLog(@"Oh oh. Could not get location. Should explode.");
    } else {
      NSLog(@"long! %f", location.coordinate.longitude);
      NSLog(@"lat! %f", location.coordinate.latitude);
      
      self.latitude = location.coordinate.latitude;
      self.longitude = location.coordinate.longitude;
      self.recordedAt = [NSDate date];
      self.name = @"Untitled";
      self.friendlyName = @"Untitled";
      self.memo = @"No memo";
      
      if([[NSUserDefaults standardUserDefaults] boolForKey:@"LocationsUseGeocoder"]) {
        NSLog(@"Geocoder time!");
        [self geocode:^(NSError *error){
          NSLog(@"self.store %@", self.store);
          [self.store insertOrUpdatePoint:self];
          completionHandler();
        }];
      } else {
        NSLog(@"No geocoder here baby! %@", [[NSUserDefaults standardUserDefaults] boolForKey:@"LocationsUseGeocoder"] ? @"YES" : @"NO");
        [self determineDefaultName:nil];
        NSLog(@"self.store %@", self.store);
        [self.store insertOrUpdatePoint:self];
        completionHandler();
      }
      
    }
  }];
}

#pragma mark -
#pragma mark Geocoder

-(void)geocode:(void (^)(NSError*))completionHandler {
  
//  UIApplication *app = [UIApplication sharedApplication];
//  NSAssert(self->bgTask == UIBackgroundTaskInvalid, nil);
//  
//  self->bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//  }];
//		if (self->bgTask != UIBackgroundTaskInvalid) {
//      [[UIApplication sharedApplication] endBackgroundTask:self->bgTask];
//      self->bgTask = UIBackgroundTaskInvalid;
//    }
  
  CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
  
  NSLog(@"Geocoding %@", location);
  
  [[PQGLocationHelper sharedHelper] geocode:location completionHandler:^(NSArray *placemarks, NSError *error) {
    if(error || placemarks.count == 0) {
      self.friendlyName = @"Geocoder Unavailable";
    } else {
      [self reverseGeocoderDidFindPlacemark:placemarks[0]];
    }
    completionHandler(error);
  }];
}

- (void)reverseGeocoderDidFindPlacemark:(CLPlacemark *)placemark {
	NSString *simpleName = placemark.country;
  
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
  
  if(placemark.areasOfInterest && placemark.areasOfInterest.count == 1) {
    simpleName = placemark.areasOfInterest.firstObject;
  }
	
	[self determineDefaultName:simpleName];
	NSString *address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
  
//  address = [address stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
  
  self.friendlyName = address;
  //  DLog(@"region %@", placemark.region);
}


@end
