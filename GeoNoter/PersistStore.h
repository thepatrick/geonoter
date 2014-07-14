//
//  PersistStore.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 14/03/08.
//  Copyright 2008-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SQLDatabase;
@class Trip;
@class Tag;
@class GNPoint;
@class GNAttachment;

@interface PersistStore : NSObject

@property (strong, nonatomic) SQLDatabase *db;

# pragma mark - Helpers
+ (NSString*)pathForResource:(NSString*)path;
+ (NSString*)attachmentsDirectory;
+ (NSURL*)pathForCacheResource:(NSString*)path;
+ (NSURL*)attachmentsCacheDirectory;
+ (NSURL*)attachmentCacheURL:(NSString*)attachmentName;

# pragma mark - Store API
+ (instancetype)storeWithFile:(NSString*)file;

- (BOOL)openDatabase:(NSString *)fileName;
- (void)closeDatabase;
- (void)migrateFrom:(NSInteger)version;

- (void)tellCacheToDehydrate;
- (void)tellCacheToSave;

- (void)lock:(void(^)())block;

#pragma mark - Tags
- (BOOL)insertOrUpdateTag:(Tag*)tag;
- (void)deleteTagFromStore:(NSInteger)tagId;
- (void)removeTagFromCache:(NSInteger)tagId;
- (NSArray*)getTagsWithConditions:(NSString*)conditions andSort:(NSString*)sort;
- (NSArray*)getAllTags;
- (Tag*)getTag:(NSInteger)tagId;


#pragma mark - Points
- (BOOL)insertOrUpdatePoint:(GNPoint*)point;
- (void)deletePointFromStore:(NSInteger)pointId;
- (void)removePointFromCache:(NSInteger)pointId;
- (NSArray*)getPointsWithConditions:(NSString*)conditions andSort:(NSString*)sort;
- (NSArray*)getAllPoints;
- (GNPoint*)getPoint:(NSInteger)pointId;
- (void)removeTag:(NSInteger)tagId fromPoint:(NSInteger)pointId;
- (void)removeTagsFromPoint:(NSInteger)pointId;
- (void)addTag:(NSInteger)tagId toPoint:(NSInteger)pointId;

#pragma mark - Attachments
- (BOOL)insertOrUpdateAttachment:(GNAttachment*)attachment;
- (void)deleteAttachmentFromStore:(NSInteger)attachmentId;
- (void)removeAttachmentFromCache:(NSInteger)attachmentId;
- (NSMutableArray*)getAttachmentsWithConditions:(NSString*)conditions andSort:(NSString*)sort;
- (NSMutableArray*)getAllAttachments;
- (GNAttachment*)getAttachment:(NSInteger)attachmentId;

@end
