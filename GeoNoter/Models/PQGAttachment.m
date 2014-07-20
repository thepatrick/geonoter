//
//  PQGAttachment.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 20/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

#import "PQGAttachment.h"
#import "PersistStore.h"

#import "NSDateJSON.h"
#import "NSStringUUID.h"
#import "UIImageContentsOfFileURL.h"
#import "UIImageSizer.h"

@interface PQGAttachment()

@property (nonatomic, copy) NSString *friendly_name;
@property (nonatomic, copy) NSString *file_name;
@property (nonatomic, copy) NSDate *recorded_at;

@end


@implementation PQGAttachment

//- (NSString *)description {
//  return [NSString stringWithFormat:@"<%@> ID: '%@'. File Name: '%@'. Name: '%@'. Point: %ld", [self class], self.dbId, self.fileName, self.friendlyName, (long)self.pointId];
//}

#pragma mark - Map underscore to camelcase

- (NSString*)friendlyName {
  return self.friendly_name;
}

- (void)setFriendlyName:(NSString *)friendlyName {
  self.friendly_name = friendlyName;
}


- (NSString*)fileName {
  return self.file_name;
}

- (void)setFileName:(NSString *)fileName {
  self.file_name = fileName;
}

- (NSDate*)recordedAt {
  return self.recorded_at;
}

- (void)setRecordedAt:(NSDate *)recordedAt {
  self.recorded_at = recordedAt;
}

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

#pragma mark - File system

- (NSString*)filesystemPath {
  return [[PersistStore attachmentsDirectory] stringByAppendingPathComponent:self.fileName];
}

-(FCModelSaveResult)delete {
  FCModelSaveResult result = [super delete];
  if(result == FCModelSaveSucceeded) {
    [[NSFileManager defaultManager] removeItemAtPath:[self filesystemPath] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[[self filesystemPath] stringByAppendingString:@".cached.jpg"] error:nil];
    // @TODO Remove any cached items too!
  }
  return result;
}

- (NSData*)data {
  return [NSData dataWithContentsOfFile:self.filesystemPath];
}

- (UIImage*)loadCachedImageForSize:(NSInteger)largestSide {
  NSURL *cachedPath = [PersistStore attachmentCacheURL:[NSString stringWithFormat:@"%ld-%@", largestSide, self.fileName]];
  if([[NSFileManager defaultManager] fileExistsAtPath:cachedPath.path]) {
    UIImage *cachedImage = [[UIImage alloc] initWithContentsOfFileURL:cachedPath];
    NSLog(@"Loaded %@ from cache %@", self.fileName, cachedPath);
    return cachedImage;
  } else {
    UIImage *original = [UIImage imageWithContentsOfFile:self.filesystemPath];
    NSLog(@"img: %f x %f", original.size.width, original.size.height);
    UIImage *newCachedImage = [original pqg_scaleAndRotateImage:largestSide];
    NSLog(@"img: %f x %f", newCachedImage.size.width, newCachedImage.size.height);
    NSData *data = UIImageJPEGRepresentation(newCachedImage, 1.0);
    [data writeToURL:cachedPath atomically:YES];
    NSLog(@"Wrote %@ to cache %@", self.fileName, cachedPath);
    return newCachedImage;
  }
}

@end
