//
//  PersistStore.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 14/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import "SQLDatabase.h"
#import "PersistStore.h"
#import "Movie.h"
#import "Trip.h"
#import "Tag.h"
#import "GNPoint.h"
#import "GNAttachment.h"
#import "NSDateJSON.h"

@implementation PersistStore

@synthesize db;

+storeWithFile:(NSString*)file
{
	PersistStore *store = [[[PersistStore alloc] init] autorelease];
	[store openDatabase:file];
	return store;
}

-init
{
	if(self = [super init]) {
		dbIsOpen = NO;
		dbLock = NO;
		centralTripStore = [[NSMutableDictionary dictionaryWithCapacity:500] retain];
		centralTagStore = [[NSMutableDictionary dictionaryWithCapacity:500] retain];
		centralPointStore = [[NSMutableDictionary dictionaryWithCapacity:500] retain];
		centralAttachmentStore = [[NSMutableDictionary dictionaryWithCapacity:500] retain];
		dbLock = [[NSLock alloc] init];
	}	
	return self;
}

-(void)dealloc {
	if(dbIsOpen) {
		[self closeDatabase];
	}
	[centralTripStore release];
	[centralTagStore release];
	[centralPointStore release];
	[centralAttachmentStore release];
	[dbLock release];
    [super dealloc];
}

-(BOOL)openDatabase:(NSString *)fileName
{	
	BOOL newFile = ![[NSFileManager defaultManager] fileExistsAtPath:fileName];
	self.db = [SQLDatabase databaseWithFile:fileName];
	[db open];
	dbIsOpen = YES;

	if(newFile) {
		DLog(@"First run, create basic file format");
		[db performQuery:@"CREATE TABLE sync_status_and_version (last_sync datetime, version integer)"];
		[db performQuery:@"INSERT INTO sync_status_and_version VALUES (NULL, 0)"];
	}

	SQLResult *res = [db performQuery:@"SELECT last_sync, version FROM sync_status_and_version;"];
	SQLRow *row = [res rowAtIndex:0];
	
	NSString *version = [row stringForColumn:@"version"];
	
	
	int theVersion = [version integerValue];
	
	DLog(@"Database: Version: '%d'", theVersion);
	
	[self migrateFrom:theVersion];
	
	return YES;
}

-(void)closeDatabase
{
	dbIsOpen = NO;
	[db performQuery:@"COMMIT"];
	[db close];
}

-(void)migrateFrom:(NSInteger)version
{
	if(version < 1) {
		DLog(@"Database migrating to v1...");
		
		[db performQuery:@"CREATE TABLE trip (id INTEGER PRIMARY KEY, name TEXT, start DATETIME, end DATETIME)"];
		
		[db performQuery:@"UPDATE sync_status_and_version SET version = 1"];
		DLog(@"Database migrated to v1.");
	}
	if(version < 2) {
		DLog(@"Database migrating to v2...");
		
		[db performQuery:@"INSERT INTO trip (name, start, end) VALUES ('Test Trip', '2008-01-01', '2008-12-31')"];
		
		[db performQuery:@"UPDATE sync_status_and_version SET version = 2"];
		DLog(@"Database migrated to v2.");
	}
	if(version < 3) {
		DLog(@"Database migrating to v3...");

		[db performQuery:@"CREATE TABLE tag (id INTEGER PRIMARY KEY, name TEXT)"];
		[db performQuery:@"CREATE TABLE trip_tag (trip_id INTEGER, tag_id INTEGER)"];
		[db performQuery:@"CREATE TABLE point (id INTEGER PRIMARY KEY, trip_id INTEGER, friendly_name TEXT, name TEXT, memo TEXT, recorded_at DATETIME, latitude NUMBER, longitude NUMBER)"];
		[db performQuery:@"CREATE TABLE point_tag (point_id INTEGER, tag_id INTEGER)"];
		
		[db performQuery:@"UPDATE sync_status_and_version SET version = 3"];
		DLog(@"Database migrated to v3.");
	}
	if(version < 4) {
		DLog(@"Database migrating to v4...");
		
		[db performQuery:@"INSERT INTO tag (name) VALUES ('Test Tag')"];
		[db performQuery:@"INSERT INTO tag (name) VALUES ('Personal')"];

		[db performQuery:@"UPDATE sync_status_and_version SET version = 4"];
		DLog(@"Database migrated to v4.");
	}
	if(version < 5) {
		DLog(@"Database migrating to v5...");

		[db performQuery:@"INSERT INTO point (trip_id, friendly_name, name, memo, recorded_at, latitude, longitude) VALUES (1, 'Vancouver BC, Canada', 'Home', 'No memo', '2009-01-12 21:18:00', 49.283588, -123.126373)"];
		[db performQuery:@"INSERT INTO point_tag (point_id, tag_id) VALUES (1, 1)"];
		[db performQuery:@"INSERT INTO point_tag (point_id, tag_id) VALUES (1, 2)"];
		
		[db performQuery:@"UPDATE sync_status_and_version SET version = 5"];
		DLog(@"Database migrated to v5.");
	}
	
	if(version < 6) {
		DLog(@"Database migrating to v6...");
		
		[db performQuery:@"CREATE TABLE attachment (id INTEGER PRIMARY KEY, point_id INTEGER, friendly_name TEXT, kind TEXT, memo TEXT, file_name TEXT, recorded_at DATETIME)"];
		
		[db performQuery:@"UPDATE sync_status_and_version SET version = 6"];
		DLog(@"Database migrated to v5.");
	}
}
-(void)tellCacheToSave
{
	[[centralTripStore allValues] makeObjectsPerformSelector:@selector(save)];
	[[centralTagStore allValues] makeObjectsPerformSelector:@selector(save)];
	[[centralPointStore allValues] makeObjectsPerformSelector:@selector(save)];
	[[centralAttachmentStore allValues] makeObjectsPerformSelector:@selector(save)];
	
}

-(void)tellCacheToDehydrate
{
	[[centralTripStore allValues] makeObjectsPerformSelector:@selector(dehydrate)];
	[[centralTagStore allValues] makeObjectsPerformSelector:@selector(dehydrate)];
	[[centralPointStore allValues] makeObjectsPerformSelector:@selector(dehydrate)];
	[[centralAttachmentStore allValues] makeObjectsPerformSelector:@selector(dehydrate)];

}

#pragma mark -
#pragma mark Trips

-(NSInteger)insertTrip:(Trip*)trip
{	
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO trip (id, name, start, end) VALUES (%@, '%@', '%@', '%@')",
					 @"NULL",
					 [SQLDatabase prepareStringForQuery:trip.name],
					 [trip.start sqlDateString],
					 [trip.end sqlDateString]];
	DLog(@"insertTrip: SQL: %@", sql);
	[dbLock lock];
	[db performQuery:sql];	
	[dbLock unlock];
	
	[dbLock lock];
	SQLResult *res = [db performQueryWithFormat:@"SELECT max(id) FROM trip"];
	if(!res) {
		[db performQuery:@"ROLLBACK"];
	}
	SQLRow *row = [res rowAtIndex:0];
	if(!row) {
		[db performQuery:@"ROLLBACK"];
	}
	
	NSInteger newTripID = [row integerForColumnAtIndex:0];
	trip.dbId = [NSNumber numberWithInteger:newTripID];
	[dbLock unlock];
	
	return newTripID;
}

-(BOOL)insertOrUpdateTrip:(Trip*)trip
{
	BOOL shouldInsert = (trip.dbId == nil);
	
	if(shouldInsert) {
		[self insertTrip:trip];
	} else { // shouldInsert == NO.
		NSString *sql = [NSString stringWithFormat:@"UPDATE trip SET name = '%@', start = '%@', end = '%@' WHERE id = %@",
						 [SQLDatabase prepareStringForQuery:trip.name],
						 trip.start,
						 trip.end,
						 trip.dbId];
		[dbLock lock];
		[db performQuery:sql];	
		[dbLock unlock];
	}
	return shouldInsert;
}

-(void)deleteTripFromStore:(NSInteger)tripId
{
	[self removeTripFromCache:tripId];
	[db performQueryWithFormat:@"DELETE FROM trip WHERE id = %d", tripId];
}


-(void)removeTripFromCache:(NSInteger)tripId
{
	[centralTripStore removeObjectForKey:[NSString stringWithFormat:@"%d", tripId]];
}

-(NSMutableArray*)getTripsWithConditions:(NSString*)conditions andSort:(NSString*)sort
{
	[dbLock lock];
	NSMutableArray *array = [NSMutableArray array];
	SQLResult *res = [db performQueryWithFormat:@"SELECT id FROM trip %@ ORDER BY %@", 
					  (conditions != nil ? [@"WHERE " stringByAppendingString:conditions] : @""),
					  (sort != nil ? sort : @"name ASC")];
	
	
	SQLRow *row;
	for(row in [res rowEnumerator]) {
		Trip *trip = [self getTrip:[row integerForColumn:@"id"]];
		[array addObject:trip];
	}
	[dbLock unlock];

	return array;
}



-(NSMutableArray*)getAllTrips
{
	return [self getTripsWithConditions:nil andSort:nil];
}

-(Trip*)getTrip:(NSInteger)tripId
{
	Trip *theTrip = [centralTripStore objectForKey:[NSString stringWithFormat:@"%d", tripId]];
	if(theTrip == nil) {
		NSString *theKey = [NSString stringWithFormat:@"%d", tripId];
		theTrip = [Trip tripWithPrimaryKey:tripId andStore:self];
		[centralTripStore setObject:theTrip forKey:theKey];
	}
	return theTrip;
}

#pragma mark -
#pragma mark Tags

-(NSInteger)insertTag:(Tag*)tag
{	
	DLog(@"insert tag!");
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO tag (name) VALUES ('%@')",
					 [SQLDatabase prepareStringForQuery:tag.name]];
	
	[dbLock lock];
	[db performQuery:sql];	
	[dbLock unlock];
	
	[dbLock lock];
	SQLResult *res = [db performQueryWithFormat:@"SELECT max(id) FROM tag"];
	if(!res) {
		[db performQuery:@"ROLLBACK"];
	}
	SQLRow *row = [res rowAtIndex:0];
	if(!row) {
		[db performQuery:@"ROLLBACK"];
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
		[db performQuery:sql];	
		[dbLock unlock];
	}
	return shouldInsert;
}

-(void)deleteTagFromStore:(NSInteger)tagId
{
	// remove any pointa ssociations!
	[self removeTagFromCache:tagId];
	[dbLock lock];
	[db performQueryWithFormat:@"DELETE FROM point_tag WHERE tag_id = %d", tagId];
	[db performQueryWithFormat:@"DELETE FROM tag WHERE id = %d", tagId];
	[dbLock unlock];
}

-(void)removeTagFromCache:(NSInteger)tagId
{
	[centralTagStore removeObjectForKey:[NSString stringWithFormat:@"%d", tagId]];
}

-(NSMutableArray*)getTagsWithConditions:(NSString*)conditions andSort:(NSString*)sort
{
	[dbLock lock];
	NSMutableArray *array = [NSMutableArray array];
	SQLResult *res = [db performQueryWithFormat:@"SELECT id FROM tag %@ ORDER BY %@", 
					  (conditions != nil ? [@"WHERE " stringByAppendingString:conditions] : @""),
					  (sort != nil ? sort : @"name ASC")];
	
	
	SQLRow *row;
	for(row in [res rowEnumerator]) {
		Tag *tag = [self getTag:[row integerForColumn:@"id"]];
		[array addObject:tag];
	}
	[dbLock unlock];
	
	return array;
}



-(NSMutableArray*)getAllTags
{
	return [self getTagsWithConditions:nil andSort:nil];
}

-(Tag*)getTag:(NSInteger)tagId
{
	Tag *theTag = [centralTagStore objectForKey:[NSString stringWithFormat:@"%d", tagId]];
	if(theTag == nil) {
		NSString *theKey = [NSString stringWithFormat:@"%d", tagId];
		theTag = [Tag tagWithPrimaryKey:tagId andStore:self];
		[centralTagStore setObject:theTag forKey:theKey];
	}
	return theTag;
}


#pragma mark -
#pragma mark Points

-(NSInteger)insertPoint:(GNPoint*)point
{	
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO point (trip_id, friendly_name, name, memo, recorded_at, latitude, longitude) VALUES (%d, '%@', '%@', '%@', '%@', %f, %f)",
					 point.tripId,
					 [SQLDatabase prepareStringForQuery:point.friendlyName],
					 [SQLDatabase prepareStringForQuery:point.name],
					 [SQLDatabase prepareStringForQuery:point.memo],
					 [point.recordedAt sqlDateString],
					 point.latitude,
					 point.longitude];
	
	[dbLock lock];
	[db performQuery:sql];	
	[dbLock unlock];
	
	[dbLock lock];
	SQLResult *res = [db performQueryWithFormat:@"SELECT max(id) FROM point"];
	if(!res) {
		[db performQuery:@"ROLLBACK"];
	}
	SQLRow *row = [res rowAtIndex:0];
	if(!row) {
		[db performQuery:@"ROLLBACK"];
	}
	
	NSInteger newPointID = [row integerForColumnAtIndex:0];
	point.dbId = [NSNumber numberWithInteger:newPointID];
	[dbLock unlock];
	
	return newPointID;
}

-(BOOL)insertOrUpdatePoint:(GNPoint*)point
{
	DLog(@"Inserting/Updating Point! %@", point);
	BOOL shouldInsert = (point.dbId == nil);
	
	if(shouldInsert) {
		[self insertPoint:point];
	} else { // shouldInsert == NO.
		
		NSString *sql = [NSString stringWithFormat:@"UPDATE point SET trip_id = %d, friendly_name = '%@', name = '%@', memo = '%@', recorded_at = '%@', latitude = %f, longitude = %f WHERE id = %@",
						 point.tripId,
						 [SQLDatabase prepareStringForQuery:point.friendlyName],
						 [SQLDatabase prepareStringForQuery:point.name],
						 [SQLDatabase prepareStringForQuery:point.memo],
						 [point.recordedAt sqlDateString],
						 point.latitude,
						 point.longitude,
						 point.dbId];
		
		DLog(@"Execute query: %@", sql);
		
		[dbLock lock];
		[db performQuery:sql];	
		[dbLock unlock];
	}
	return shouldInsert;
}

-(void)deletePointFromStore:(NSInteger)pointId
{
	[self removePointFromCache:pointId];
	[dbLock lock];
	[db performQueryWithFormat:@"DELETE FROM point_trip WHERE point_id = %d", pointId];
	[db performQueryWithFormat:@"DELETE FROM point WHERE id = %d", pointId];
	[dbLock unlock];
}


-(void)removePointFromCache:(NSInteger)tagId
{
	[centralPointStore removeObjectForKey:[NSString stringWithFormat:@"%d", tagId]];
}

-(NSMutableArray*)getPointsWithConditions:(NSString*)conditions andSort:(NSString*)sort
{
	[dbLock lock];
	NSMutableArray *array = [NSMutableArray array];
	SQLResult *res = [db performQueryWithFormat:@"SELECT id FROM point %@ ORDER BY %@", 
					  (conditions != nil ? [@"WHERE " stringByAppendingString:conditions] : @""),
					  (sort != nil ? sort : @"name ASC")];
	
	
	SQLRow *row;
	for(row in [res rowEnumerator]) {
		GNPoint *point = [self getPoint:[row integerForColumn:@"id"]];
		[array addObject:point];
	}
	[dbLock unlock];
	
	return array;
}



-(NSMutableArray*)getAllPoints
{
	return [self getPointsWithConditions:nil andSort:nil];
}

-(GNPoint*)getPoint:(NSInteger)tagId
{
	GNPoint *thePoint = [centralPointStore objectForKey:[NSString stringWithFormat:@"%d", tagId]];
	if(thePoint == nil) {
		NSString *theKey = [NSString stringWithFormat:@"%d", tagId];
		thePoint = [GNPoint pointWithPrimaryKey:tagId andStore:self];
		[centralPointStore setObject:thePoint forKey:theKey];
	}
	return thePoint;
}

-(void)removeTagFromPoint:(NSInteger)pointId
{
	[dbLock lock];
	[db performQueryWithFormat:@"DELETE FROM point_tag WHERE point_id = %d", pointId];
	[dbLock unlock];
}

-(void)addTag:(NSInteger)tagId toPoint:(NSInteger)pointId {
	DLog(@"WTF Why am I not being called?!");
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO point_tag (tag_id, point_id) VALUES (%d, %d)",
					 tagId, pointId];
	DLog(@"addTag:toPoint: SQL %@", sql);
	[dbLock lock];
	[db performQuery:sql];
	[dbLock unlock];
}


#pragma mark -
#pragma mark Attachments
-(NSInteger)insertAttachment:(GNAttachment*)attachment
{	
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO attachment (point_id, friendly_name, kind, memo, recorded_at, file_name) VALUES (%d, '%@', '%@', '%@', '%@', '%@')",
					 attachment.pointId,
					 [SQLDatabase prepareStringForQuery:attachment.friendlyName],
					 [SQLDatabase prepareStringForQuery:attachment.kind],
					 [SQLDatabase prepareStringForQuery:attachment.memo],
					 [attachment.recordedAt sqlDateString],
					 [SQLDatabase prepareStringForQuery:attachment.fileName]];
	
	[dbLock lock];
	[db performQuery:sql];	
	[dbLock unlock];
	
	[dbLock lock];
	SQLResult *res = [db performQueryWithFormat:@"SELECT max(id) FROM attachment"];
	if(!res) {
		[db performQuery:@"ROLLBACK"];
	}
	SQLRow *row = [res rowAtIndex:0];
	if(!row) {
		[db performQuery:@"ROLLBACK"];
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
		
		
		NSString *sql = [NSString stringWithFormat:@"UPDATE attachment set point_id = %d, friendly_name = '%@', kind = '%@', memo = '%@', recorded_at = '%@', file_name = '%@' where id = %d",
						 attachment.pointId,
						 [SQLDatabase prepareStringForQuery:attachment.friendlyName],
						 [SQLDatabase prepareStringForQuery:attachment.kind],
						 [SQLDatabase prepareStringForQuery:attachment.memo],
						 [attachment.recordedAt sqlDateString],
						 [SQLDatabase prepareStringForQuery:attachment.fileName],
						 attachment.dbId];
		
		DLog(@"Execute query: %@", sql);
		
		[dbLock lock];
		[db performQuery:sql];	
		[dbLock unlock];
	}
	return shouldInsert;
}

-(void)deleteAttachmentFromStore:(NSInteger)attachmentId
{
	[self removeAttachmentFromCache:attachmentId];
	[dbLock lock];
	[db performQueryWithFormat:@"DELETE FROM attachment WHERE id = %d", attachmentId];
	[dbLock unlock];
}

-(void)removeAttachmentFromCache:(NSInteger)attachmentId
{
	[centralAttachmentStore removeObjectForKey:[NSString stringWithFormat:@"%d", attachmentId]];
}

-(NSMutableArray*)getAttachmentsWithConditions:(NSString*)conditions andSort:(NSString*)sort
{
	[dbLock lock];
	NSMutableArray *array = [NSMutableArray array];
	SQLResult *res = [db performQueryWithFormat:@"SELECT id FROM attachment %@ ORDER BY %@", 
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
	GNAttachment *theAttachment = [centralAttachmentStore objectForKey:[NSString stringWithFormat:@"%d", attachmentId]];
	if(theAttachment == nil) {
		NSString *theKey = [NSString stringWithFormat:@"%d", attachmentId];
		theAttachment = [GNAttachment attachmentWithPrimaryKey:attachmentId andStore:self];
		[centralAttachmentStore setObject:theAttachment forKey:theKey];
	}
	return theAttachment;
}


@end
