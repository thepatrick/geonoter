//
//  PQGPoint.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 20/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>

#import "GeoNoter-Swift.h"
#import "PersistStore.h"

#import "NSDateJSON.h"
#import "NSStringUUID.h"

#import "PQGPoint.h"

@interface PQGPoint()
  @property (nonatomic, copy) NSString *friendly_name;
  @property (nonatomic, copy) NSDate *recorded_at;
@end

@implementation PQGPoint

+ (NSArray*)allInstances {
  return [self instancesOrderedBy:@"name ASC"];
}

#pragma mark - Map underscore to camelcase

- (NSString*)friendlyName {
  return self.friendly_name;
}

- (void)setFriendlyName:(NSString *)friendlyName {
  self.friendly_name = friendlyName;
}

- (NSDate*)recordedAt {
  return self.recorded_at;
}

- (void)setRecordedAt:(NSDate *)recordedAt {
  self.recorded_at = recordedAt;
}


//- (NSString *)description
//{
//  return [NSString stringWithFormat:@"<%@> ID: '%@'. Name: '%@'.", [self class], self.dbId, self.name];
//}

#pragma mark - FCModel

- (id)serializedDatabaseRepresentationOfValue:(id)instanceValue forPropertyNamed:(NSString *)propertyName {
  if([propertyName isEqualToString:@"recorded_at"]) {
    NSDate *instanceDate = instanceValue;
    return [instanceDate pqg_sqlDateString];
  } else {
    return [super serializedDatabaseRepresentationOfValue:instanceValue forPropertyNamed:propertyName];
  }
}

- (id)unserializedRepresentationOfDatabaseValue:(id)databaseValue forPropertyNamed:(NSString *)propertyName {
  if([propertyName isEqualToString:@"recorded_at"]) {
    return [NSDate pqg_dateWithSQLString:databaseValue];
  } else {
    return [super unserializedRepresentationOfDatabaseValue:databaseValue forPropertyNamed:propertyName];
  }
}

#pragma mark - Tags

-(NSArray*)tags {
  return [PQGTag instancesWhere:@"id IN (select tag_id FROM point_tag WHERE point_id = ?) ORDER BY name ASC", self.id];
}

-(void)addTag:(PQGTag*)tag {
//  [FCD]
  DLog(@"Add tag... %lld", tag.id);
  [FCModel executeUpdateQuery:@"INSERT INTO point_tag (tag_id, point_id) VALUES (?, ?)", tag.id, self.id];
}

-(void)removeTag:(PQGTag*)tag {
  DLog(@"Removing exist tag... %lld", tag.id);
  [FCModel executeUpdateQuery:@"DELETE FROM point_tag WHERE tag_id = ? AND point_id = ?", tag.id, self.id];
}

#pragma mark - Attachments

-(NSArray*)attachments {
  return [PQGAttachment instancesWhere:@"point_id = ? ORDER BY recorded_at ASC", self.id];
}

-(PQGAttachment*)addAttachment:(NSData*)attachment withExtension:(NSString *)extension {
  
  NSString *fileName = [[NSString stringWithUUID] stringByAppendingPathExtension:extension];
  NSString *actualFile = [[PersistStore attachmentsDirectory] stringByAppendingPathComponent:fileName];
  
  [attachment writeToFile:actualFile atomically:YES];
  
  PQGAttachment *newAttachment = [PQGAttachment new];

  newAttachment.fileName = fileName;
  newAttachment.kind = extension;
  newAttachment.pointId = self.id;
  
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
          [self save];
          completionHandler();
        }];
      } else {
        NSLog(@"No geocoder here baby! %@", [[NSUserDefaults standardUserDefaults] boolForKey:@"LocationsUseGeocoder"] ? @"YES" : @"NO");
        [self determineDefaultName:nil];
        [self save];
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
  
  self.friendlyName = address;
}

@end
