//
//  PersistStore.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 14/03/08.
//  Copyright 2008-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "SQLDatabase.h"
#import "PersistStore.h"
#import "Tag.h"
#import "GNPoint.h"
#import "GNAttachment.h"
#import "NSDateJSON.h"

@interface PersistStore()
{
    NSLock *dbLock;
}

@property (strong, nonatomic) NSMutableDictionary *centralTripStore;
@property (strong, nonatomic) NSMutableDictionary *centralTagStore;
@property (strong, nonatomic) NSMutableDictionary *centralPointStore;
@property (strong, nonatomic) NSMutableDictionary *centralAttachmentStore;
@property (nonatomic) BOOL dbIsOpen;

@end

@implementation PersistStore

#pragma mark -
#pragma mark Filesystem stuff

// Creates a writable copy of the bundled default database in the application Documents directory.
+ (NSString*)pathForResource:(NSString*)path
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSAssert([[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory], @"Documents directory does not exist.");
  return [documentsDirectory stringByAppendingPathComponent:path];
}

+ (NSString*)attachmentsDirectory
{
    NSString *dir = [self pathForResource:@"Attachments"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    if(![fileManager fileExistsAtPath:dir isDirectory:&isDirectory]) {
        NSError *err;
        BOOL success = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
        
        if (!success) {
            NSAssert(0, @"Failed to create Attachments directory.");
        }
    }
    
    return dir;
}

+ (NSURL*)pathForCacheResource:(NSString*)path {
  NSError *err;
  NSURL *pathURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&err];
  if(!pathURL) {
    NSLog(@"Failed to get caches directory %@", err);
    NSAssert(pathURL != nil, @"Failed to get caches directory");
  }
  return [pathURL URLByAppendingPathComponent:path];
}

+ (NSURL*)attachmentsCacheDirectory {
  NSURL *dir = [self.class pathForCacheResource:@"Attachments"];
  
  BOOL isDirectory;
  if(![[NSFileManager defaultManager] fileExistsAtPath:dir.path isDirectory:&isDirectory]) {
    NSError *err;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:dir.path
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:&err];
    NSAssert(success, @"Failed to create attachments cache directory");
    isDirectory = YES;
  }
  
  NSAssert(isDirectory, @"Caches/Attachments exists but is not a directory.");
  
  return dir;
}

+ (NSURL*)attachmentCacheURL:(NSString*)attachmentName {
  return [[self attachmentsCacheDirectory] URLByAppendingPathComponent:attachmentName];
}

+(instancetype)storeWithFile:(NSString*)file
{
	PersistStore *store = [[PersistStore alloc] init];
	[store openDatabase:file];
	return store;
}

-(instancetype)init
{
	if(self = [super init]) {
		self.dbIsOpen = NO;
		self.centralTripStore = [NSMutableDictionary dictionary];
		self.centralTagStore = [NSMutableDictionary dictionary];
		self.centralPointStore = [NSMutableDictionary dictionary];
		self.centralAttachmentStore = [NSMutableDictionary dictionary];
//        self.dbLock = dispatch_queue_create("PersistStoreDBLock", DISPATCH_QUEUE_SERIAL);
        dbLock = [[NSLock alloc] init];
	}
	return self;
}

-(void)dealloc
{
	if(self.dbIsOpen) {
		[self closeDatabase];
	}
}

-(BOOL)openDatabase:(NSString *)fileName
{	
	BOOL newFile = ![[NSFileManager defaultManager] fileExistsAtPath:fileName];
	self.db = [SQLDatabase databaseWithFile:fileName];
	[self.db open];
	self.dbIsOpen = YES;

	if(newFile) {
		DLog(@"First run, create basic file format");
		[self.db performQuery:@"CREATE TABLE sync_status_and_version (last_sync datetime, version integer)"];
		[self.db performQuery:@"INSERT INTO sync_status_and_version VALUES (NULL, 0)"];
	}

	SQLResult *res = [self.db performQuery:@"SELECT last_sync, version FROM sync_status_and_version;"];
	SQLRow *row = [res rowAtIndex:0];
	
	NSString *version = [row stringForColumn:@"version"];
	
	
	NSInteger theVersion = [version integerValue];
	
	DLog(@"Database: Version: '%ld'", (long)theVersion);
	
	[self migrateFrom:theVersion];
	
	return YES;
}

-(void)closeDatabase
{
	self.dbIsOpen = NO;
	[self.db performQuery:@"COMMIT"];
	[self.db close];
}

-(void)migrateFrom:(NSInteger)version
{
	if(version < 1) {
		DLog(@"Database migrating to v1...");
        
        [self.db performQueries:@[
                                  @"CREATE TABLE trip (id INTEGER PRIMARY KEY, name TEXT, start DATETIME, end DATETIME)",
                                  @"UPDATE sync_status_and_version SET version = 1"
                                  ]];
        DLog(@"Database migrated to v1.");
	}
	if(version < 2) {
		DLog(@"Database migrating to v2...");
        [self.db performQueries:@[
            @"INSERT INTO trip (name, start, end) VALUES ('Test Trip', '2008-01-01', '2008-12-31')",
            @"UPDATE sync_status_and_version SET version = 2"
        ]];
		DLog(@"Database migrated to v2.");
	}
	if(version < 3) {
		DLog(@"Database migrating to v3...");
        [self.db performQueries:@[
            @"CREATE TABLE tag (id INTEGER PRIMARY KEY, name TEXT)",
            @"CREATE TABLE trip_tag (trip_id INTEGER, tag_id INTEGER)",
            @"CREATE TABLE point (id INTEGER PRIMARY KEY, trip_id INTEGER, friendly_name TEXT, name TEXT, memo TEXT, recorded_at DATETIME, latitude NUMBER, longitude NUMBER)",
            @"CREATE TABLE point_tag (point_id INTEGER, tag_id INTEGER)",
            @"UPDATE sync_status_and_version SET version = 3"
        ]];
        DLog(@"Database migrated to v3.");
	}
	if(version < 4) {
		DLog(@"Database migrating to v4...");
        [self.db performQueries:@[
		    @"INSERT INTO tag (name) VALUES ('Test Tag')",
            @"INSERT INTO tag (name) VALUES ('Personal')",
            @"UPDATE sync_status_and_version SET version = 4"
        ]];
		DLog(@"Database migrated to v4.");
	}
	if(version < 5) {
		DLog(@"Database migrating to v5...");
        [self.db performQueries:@[
            @"INSERT INTO point (trip_id, friendly_name, name, memo, recorded_at, latitude, longitude) VALUES (1, 'Vancouver BC, Canada', 'Home', 'No memo', '2009-01-12 21:18:00', 49.283588, -123.126373)",
		    @"INSERT INTO point_tag (point_id, tag_id) VALUES (1, 1)",
		    @"INSERT INTO point_tag (point_id, tag_id) VALUES (1, 2)",
		    @"UPDATE sync_status_and_version SET version = 5"
        ]];
		DLog(@"Database migrated to v5.");
	}
	
	if(version < 6) {
		DLog(@"Database migrating to v6...");
		[self.db performQueries:@[
		    @"CREATE TABLE attachment (id INTEGER PRIMARY KEY, point_id INTEGER, friendly_name TEXT, kind TEXT, memo TEXT, file_name TEXT, recorded_at DATETIME)",
		    @"UPDATE sync_status_and_version SET version = 6"
        ]];
		DLog(@"Database migrated to v5.");
	}
}
-(void)tellCacheToSave
{
	[[self.centralTripStore allValues] makeObjectsPerformSelector:@selector(save)];
	[[self.centralTagStore allValues] makeObjectsPerformSelector:@selector(save)];
	[[self.centralPointStore allValues] makeObjectsPerformSelector:@selector(save)];
	[[self.centralAttachmentStore allValues] makeObjectsPerformSelector:@selector(save)];
	
}

-(void)tellCacheToDehydrate
{
	[[self.centralTripStore allValues] makeObjectsPerformSelector:@selector(dehydrate)];
	[[self.centralTagStore allValues] makeObjectsPerformSelector:@selector(dehydrate)];
	[[self.centralPointStore allValues] makeObjectsPerformSelector:@selector(dehydrate)];
	[[self.centralAttachmentStore allValues] makeObjectsPerformSelector:@selector(dehydrate)];
}

-(void)lock:(void(^)())block
{
//    dispatch_sync(self.dbLock, block);
    [dbLock lock];
    block();
    [dbLock unlock];
}

#pragma mark -
#pragma mark Tags

-(NSInteger)insertTag:(Tag*)tag
{	
	DLog(@"insert tag!");
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO tag (name) VALUES ('%@')",
					 [SQLDatabase prepareStringForQuery:tag.name]];
	
	[dbLock lock];
	[self.db performQuery:sql];
	[dbLock unlock];
	
	[dbLock lock];
	SQLResult *res = [self.db performQueryWithFormat:@"SELECT max(id) FROM tag"];
	if(!res) {
		[self.db performQuery:@"ROLLBACK"];
	}
	SQLRow *row = [res rowAtIndex:0];
	if(!row) {
		[self.db performQuery:@"ROLLBACK"];
	}
	
	NSInteger newTagID = [row integerForColumnAtIndex:0];
	tag.dbId = [NSNumber numberWithInteger:newTagID];
	[dbLock unlock];
	
	return newTagID;
}

-(BOOL)insertOrUpdateTag:(Tag*)tag
{
	BOOL shouldInsert = (tag.dbId == nil);
	DLog(@"insertOrUpdateTag:%@", shouldInsert ? @"YES": @"NO");
	
	if(shouldInsert) {
		[self insertTag:tag];
	} else { // shouldInsert == NO.
		NSString *sql = [NSString stringWithFormat:@"UPDATE tag SET name = '%@' WHERE id = %@",
						 [SQLDatabase prepareStringForQuery:tag.name],
						 tag.dbId];
		[dbLock lock];
		[self.db performQuery:sql];
		[dbLock unlock];
	}
	return shouldInsert;
}

-(void)deleteTagFromStore:(NSInteger)tagId
{
	// remove any pointa ssociations!
	[self removeTagFromCache:tagId];
	[dbLock lock];
	[self.db performQueryWithFormat:@"DELETE FROM point_tag WHERE tag_id = %d", tagId];
	[self.db performQueryWithFormat:@"DELETE FROM tag WHERE id = %d", tagId];
	[dbLock unlock];
}

-(void)removeTagFromCache:(NSInteger)tagId
{
	[self.centralTagStore removeObjectForKey:@(tagId)];
}

-(NSArray*)getTagsWithConditions:(NSString*)conditions andSort:(NSString*)sort
{
	[dbLock lock];
	NSMutableArray *array = [NSMutableArray array];
	SQLResult *res = [self.db performQueryWithFormat:@"SELECT id FROM tag %@ ORDER BY %@",
					  (conditions != nil ? [@"WHERE " stringByAppendingString:conditions] : @""),
					  (sort != nil ? sort : @"name ASC")];
	
	
	SQLRow *row;
	for(row in [res rowEnumerator]) {
		Tag *tag = [self getTag:[row integerForColumn:@"id"]];
		[array addObject:tag];
	}
	[dbLock unlock];
	
	return [NSArray arrayWithArray:array];
}



-(NSArray*)getAllTags
{
	return [self getTagsWithConditions:nil andSort:nil];
}

-(Tag*)getTag:(NSInteger)tagId
{
  Tag *theTag = self.centralTagStore[@(tagId)];
	if(theTag == nil) {
		theTag = [Tag tagWithPrimaryKey:tagId andStore:self];
        self.centralTagStore[@(tagId)] = theTag;
	}
	return theTag;
}


#pragma mark -
#pragma mark Points

-(NSInteger)insertPoint:(GNPoint*)point
{	
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO point (friendly_name, name, memo, recorded_at, latitude, longitude) VALUES ('%@', '%@', '%@', '%@', %f, %f)",
					 [SQLDatabase prepareStringForQuery:point.friendlyName],
					 [SQLDatabase prepareStringForQuery:point.name],
					 [SQLDatabase prepareStringForQuery:point.memo],
					 [point.recordedAt pqg_sqlDateString],
					 point.latitude,
					 point.longitude];
	
	[dbLock lock];
	[self.db performQuery:sql];
  NSLog(@"did this fail?");
	[dbLock unlock];
	
	[dbLock lock];
  
  NSInteger newPointID = -1;
  
	SQLResult *res = [self.db performQueryWithFormat:@"SELECT max(id) FROM point"];
	if(!res) {
    NSLog(@"Rolling back (A)");
		[self.db performQuery:@"ROLLBACK"];
  } else {
    SQLRow *row = [res rowAtIndex:0];
    if(!row) {
      NSLog(@"Rolling back (B)");
      [self.db performQuery:@"ROLLBACK"];
    } else {
      newPointID = [row integerForColumnAtIndex:0];
      point.dbId = [NSNumber numberWithInteger:newPointID];
    }
  }
  [dbLock unlock];
  NSLog(@"returning %ld", (long)newPointID);
	return newPointID;
}

-(BOOL)insertOrUpdatePoint:(GNPoint*)point
{
	DLog(@"Inserting/Updating Point! %@", point);
	BOOL shouldInsert = (point.dbId == nil);
	
	if(shouldInsert) {
    DLog(@"should insert point!");
		[self insertPoint:point];
	} else { // shouldInsert == NO.
		
		NSString *sql = [NSString stringWithFormat:@"UPDATE point SET trip_id = %ld, friendly_name = '%@', name = '%@', memo = '%@', recorded_at = '%@', latitude = %f, longitude = %f WHERE id = %@",
						 (long)point.tripId,
						 [SQLDatabase prepareStringForQuery:point.friendlyName],
						 [SQLDatabase prepareStringForQuery:point.name],
						 [SQLDatabase prepareStringForQuery:point.memo],
						 [point.recordedAt pqg_sqlDateString],
						 point.latitude,
						 point.longitude,
						 point.dbId];
		
		DLog(@"Execute query: %@", sql);
		
		[dbLock lock];
		[self.db performQuery:sql];
		[dbLock unlock];
	}
	return shouldInsert;
}

-(void)deletePointFromStore:(NSInteger)pointId
{
	[self removePointFromCache:pointId];
	[dbLock lock];
	[self.db performQueryWithFormat:@"DELETE FROM point_trip WHERE point_id = %d", pointId];
	[self.db performQueryWithFormat:@"DELETE FROM point_tag WHERE point_id = %d", pointId];
	[self.db performQueryWithFormat:@"DELETE FROM point WHERE id = %d", pointId];
	[dbLock unlock];
}


-(void)removePointFromCache:(NSInteger)tagId
{
	[self.centralPointStore removeObjectForKey:@(tagId)];
}

-(NSArray*)getPointsWithConditions:(NSString*)conditions andSort:(NSString*)sort
{
	[dbLock lock];
	NSMutableArray *array = [NSMutableArray array];
	SQLResult *res = [self.db performQueryWithFormat:@"SELECT id FROM point %@ ORDER BY %@",
					  (conditions != nil ? [@"WHERE " stringByAppendingString:conditions] : @""),
					  (sort != nil ? sort : @"name ASC")];
	
	
	SQLRow *row;
	for(row in [res rowEnumerator]) {
		GNPoint *point = [self getPoint:[row integerForColumn:@"id"]];
		[array addObject:point];
	}
	[dbLock unlock];
	
	return [NSArray arrayWithArray:array];
}



-(NSArray*)getAllPoints
{
	return [self getPointsWithConditions:nil andSort:nil];
}

-(GNPoint*)getPoint:(NSInteger)pointId
{
  GNPoint *thePoint = self.centralPointStore[@(pointId)];
	if(thePoint == nil) {
		thePoint = [GNPoint pointWithPrimaryKey:pointId andStore:self];
        self.centralPointStore[@(pointId)] = thePoint;
	}
	return thePoint;
}

-(void)removeTag:(NSInteger)tagId fromPoint:(NSInteger)pointId {
  [dbLock lock];
  [self.db performQueryWithFormat:@"DELETE FROM point_tag WHERE point_id = %ld and tag_id = %ld", (long)pointId, (long)tagId];
  [dbLock unlock];
}

-(void)removeTagsFromPoint:(NSInteger)pointId
{
	[dbLock lock];
	[self.db performQueryWithFormat:@"DELETE FROM point_tag WHERE point_id = %ld", (long)pointId];
	[dbLock unlock];
}

-(void)addTag:(NSInteger)tagId toPoint:(NSInteger)pointId {
	DLog(@"WTF Why am I not being called?!");
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO point_tag (tag_id, point_id) VALUES (%ld, %ld)",
					 (long)tagId, (long)pointId];
	DLog(@"addTag:toPoint: SQL %@", sql);
	[dbLock lock];
	[self.db performQuery:sql];
	[dbLock unlock];
}


#pragma mark -
#pragma mark Attachments
-(NSInteger)insertAttachment:(GNAttachment*)attachment
{	
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO attachment (point_id, friendly_name, kind, memo, recorded_at, file_name) VALUES (%ld, '%@', '%@', '%@', '%@', '%@')",
					 (long)attachment.pointId,
					 [SQLDatabase prepareStringForQuery:attachment.friendlyName],
					 [SQLDatabase prepareStringForQuery:attachment.kind],
					 [SQLDatabase prepareStringForQuery:attachment.memo],
					 [attachment.recordedAt pqg_sqlDateString],
					 [SQLDatabase prepareStringForQuery:attachment.fileName]];
	
	[dbLock lock];
	[self.db performQuery:sql];
	[dbLock unlock];
	
	[dbLock lock];
	SQLResult *res = [self.db performQueryWithFormat:@"SELECT max(id) FROM attachment"];
	if(!res) {
		[self.db performQuery:@"ROLLBACK"];
	}
	SQLRow *row = [res rowAtIndex:0];
	if(!row) {
		[self.db performQuery:@"ROLLBACK"];
	}
	
	NSInteger newAttachmentID = [row integerForColumnAtIndex:0];
	attachment.dbId = [NSNumber numberWithInteger:newAttachmentID];
	[dbLock unlock];
	
	return newAttachmentID;
}

-(BOOL)insertOrUpdateAttachment:(GNAttachment*)attachment
{
	DLog(@"Inserting/Updating Attachment! %@", attachment);
	BOOL shouldInsert = (attachment.dbId == nil);
	
	if(shouldInsert) {
		[self insertAttachment:attachment];
	} else { // shouldInsert == NO.
		
		
		NSString *sql = [NSString stringWithFormat:@"UPDATE attachment set point_id = %ld, friendly_name = '%@', kind = '%@', memo = '%@', recorded_at = '%@', file_name = '%@' where id = %@",
						 (long)attachment.pointId,
						 [SQLDatabase prepareStringForQuery:attachment.friendlyName],
						 [SQLDatabase prepareStringForQuery:attachment.kind],
						 [SQLDatabase prepareStringForQuery:attachment.memo],
						 [attachment.recordedAt pqg_sqlDateString],
						 [SQLDatabase prepareStringForQuery:attachment.fileName],
						 attachment.dbId];
		
		DLog(@"Execute query: %@", sql);
		
		[dbLock lock];
		[self.db performQuery:sql];
		[dbLock unlock];
	}
	return shouldInsert;
}

-(void)deleteAttachmentFromStore:(NSInteger)attachmentId
{
	[self removeAttachmentFromCache:attachmentId];
	[dbLock lock];
	[self.db performQueryWithFormat:@"DELETE FROM attachment WHERE id = %ld", (long)attachmentId];
	[dbLock unlock];
}

-(void)removeAttachmentFromCache:(NSInteger)attachmentId
{
	[self.centralAttachmentStore removeObjectForKey:@(attachmentId)];
}

-(NSMutableArray*)getAttachmentsWithConditions:(NSString*)conditions andSort:(NSString*)sort
{
	[dbLock lock];
	NSMutableArray *array = [NSMutableArray array];
	SQLResult *res = [self.db performQueryWithFormat:@"SELECT id FROM attachment %@ ORDER BY %@",
					  (conditions != nil ? [@"WHERE " stringByAppendingString:conditions] : @""),
					  (sort != nil ? sort : @"friendly_name ASC")];
	
	
	SQLRow *row;
	for(row in [res rowEnumerator]) {
		GNAttachment *point = [self getAttachment:[row integerForColumn:@"id"]];
		[array addObject:point];
	}
	[dbLock unlock];
	
	return array;
}



-(NSMutableArray*)getAllAttachments
{
	return [self getAttachmentsWithConditions:nil andSort:nil];
}

-(GNAttachment*)getAttachment:(NSInteger)attachmentId
{
	GNAttachment *theAttachment = self.centralAttachmentStore[@(attachmentId)];
	if(theAttachment == nil) {
		theAttachment = [GNAttachment attachmentWithPrimaryKey:attachmentId andStore:self];
        self.centralAttachmentStore[@(attachmentId)] = theAttachment;
	}
	return theAttachment;
}


@end
