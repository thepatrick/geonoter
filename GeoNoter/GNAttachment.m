//
//  GNAttachment.m
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 18/02/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "SQLDatabase.h"
#import "PersistStore.h"
#import "GNAttachment.h"
#import "UIImageContentsOfFileURL.h"
#import "UIImageSizer.h"

@implementation GNAttachment

+ (instancetype)attachment {
  return [[[self class] alloc] init];
}

+ (instancetype)attachmentWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore {
  return [[[self class] alloc] initWithPrimaryKey:theID andStore:newStore];
}

- (instancetype)init {
  if(self = [super init]) {
		dirty = NO;
		hydrated = NO;
	}
	return self;
}

- (instancetype)initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore {
	if(self = [super init]) {
		self.dbId = @(theID);
		self.store = newStore;
		hydrated = NO;
		dirty = NO;
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@> ID: '%@'. File Name: '%@'. Name: '%@'. Point: %ld", [self class], self.dbId, self.fileName, self.friendlyName, (long)self.pointId];
}

- (instancetype)hydrate {
	if(self.dbId == nil || hydrated) {
		return self; // we're not going to hydrate in this situation, it's unncessary!
	}
	
	SQLResult *res = [self.store.db performQueryWithFormat:@"SELECT * FROM attachment WHERE id = %d", [self.dbId integerValue]];
	if([res rowCount] == 0) {
		NSLog(@"Didn't hydrate because the select returned 0 results, sql was %@", [NSString stringWithFormat:@"SELECT * FROM point WHERE id = %@", self.dbId]);
		return self; // bugger.
	}
	
	SQLRow *row = [res rowAtIndex:0];
	
	self.pointId = [[row stringForColumn:@"point_id"] integerValue];
	self.friendlyName = [row stringForColumn:@"friendly_name"];
	self.kind = [row stringForColumn:@"kind"];	
	self.memo = [row stringForColumn:@"memo"];	
	self.fileName = [row stringForColumn:@"file_name"];
	self.recordedAt = [row dateForColumn:@"recorded_at"];
	
	hydrated = YES;
	return self;
}

-(void)dehydrate {
	if(!hydrated) return; // no point wasting time
	
	if(self.dbId == nil) {
		return; // we're not going to dehydrate in this situation, it's unpossible!
	}
	
	[self save];
	
	_fileName = nil;
	_friendlyName = nil;
	_kind = nil;
	_memo = nil;
	_recordedAt = nil;
	
	hydrated = NO;
}

-(void)save {
	if(dirty) {
		[self.store insertOrUpdateAttachment:self];
		dirty = NO;
	}	
}

-(void)setPointId:(NSInteger)newValue {
	_pointId = newValue;
	dirty = YES;	
}

-(void)setFriendlyName:(NSString*)newValue {
	_friendlyName = [newValue copy];
	dirty = YES;	
}

-(void)setFileName:(NSString*)newValue {
	_fileName = [newValue copy];
	dirty = YES;	
}

-(void)setKind:(NSString*)newValue {
	_kind = [newValue copy];
	dirty = YES;	
}

-(void)setMemo:(NSString*)newValue {
	_memo = [newValue copy];
	dirty = YES;	
}

-(void)setRecordedAt:(NSDate*)newValue {
	_recordedAt = [newValue copy];
	dirty = YES;	
}

- (NSString*)filesystemPath {
	return [[PersistStore attachmentsDirectory] stringByAppendingPathComponent:self.fileName];
}

- (void)deleteAttachment {
	[self.store deleteAttachmentFromStore:[self.dbId integerValue]];
	[[NSFileManager defaultManager] removeItemAtPath:[self filesystemPath] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[[self filesystemPath] stringByAppendingString:@".cached.jpg"] error:nil];
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
