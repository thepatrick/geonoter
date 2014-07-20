//
//  PersistStore.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 14/03/08.
//  Copyright 2008-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "PersistStore.h"

@implementation PersistStore

#pragma mark - Filesystem stuff

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

#pragma mark - Lifecycle

+(void)openDatabase:(NSString *)fileName
{
	BOOL newFile = ![[NSFileManager defaultManager] fileExistsAtPath:fileName];
  [FCModel openDatabaseAtPath:fileName withSchemaBuilder:^(FMDatabase *db, int *schemaVersion) {
    if(newFile) {
      if(newFile) {
        DLog(@"First run, create basic file format");
        [db executeUpdate:@"CREATE TABLE sync_status_and_version (last_sync datetime, version integer)"];
        [db executeUpdate:@"INSERT INTO sync_status_and_version VALUES (NULL, 0)"];
      }
    }

    FMResultSet *s = [db executeQuery:@"SELECT last_sync, version FROM sync_status_and_version"];
    BOOL hasVersion = [s next];
    NSAssert(hasVersion, @"Unable to retrieve version from sync_status_and_version");
    NSString *version = [s stringForColumn:@"version"];
    NSInteger theVersion = [version integerValue];
    
    DLog(@"Database: Version: '%ld'", (long)theVersion);
    
    [self legacyMigrateFrom:theVersion withDatabase:db];
  }];
}

+(void)closeDatabase
{
  [FCModel closeDatabase];
}

#pragma mark - Migrations

+(void)legacyMigrateFrom:(NSInteger)version withDatabase:(FMDatabase*)db
{
	if(version < 1) {
		DLog(@"Database migrating to v1...");
    [db executeStatements:@"CREATE TABLE trip (id INTEGER PRIMARY KEY, name TEXT, start DATETIME, end DATETIME);"
                           "UPDATE sync_status_and_version SET version = 1;"];
    DLog(@"Database migrated to v1.");
	}
	if(version < 2) {
		DLog(@"Database migrating to v2...");
    [db executeStatements:@"INSERT INTO trip (name, start, end) VALUES ('Test Trip', '2008-01-01', '2008-12-31');"
                           "UPDATE sync_status_and_version SET version = 2;"];
		DLog(@"Database migrated to v2.");
	}
	if(version < 3) {
		DLog(@"Database migrating to v3...");
    [db executeStatements:
      @"CREATE TABLE tag (id INTEGER PRIMARY KEY, name TEXT);"
       "CREATE TABLE trip_tag (trip_id INTEGER, tag_id INTEGER);"
       "CREATE TABLE point (id INTEGER PRIMARY KEY, trip_id INTEGER, friendly_name TEXT, name TEXT, memo TEXT, recorded_at DATETIME, latitude NUMBER, longitude NUMBER);"
       "CREATE TABLE point_tag (point_id INTEGER, tag_id INTEGER);"
       "UPDATE sync_status_and_version SET version = 3"
    ];
    DLog(@"Database migrated to v3.");
	}
	if(version < 4) {
		DLog(@"Database migrating to v4...");
    [db executeStatements:@"INSERT INTO tag (name) VALUES ('Test Tag');"
                           "INSERT INTO tag (name) VALUES ('Personal');"
                           "UPDATE sync_status_and_version SET version = 4;"];
		DLog(@"Database migrated to v4.");
	}
	if(version < 5) {
		DLog(@"Database migrating to v5...");
    [db executeStatements:
      @"INSERT INTO point (trip_id, friendly_name, name, memo, recorded_at, latitude, longitude) VALUES (1, 'Vancouver BC, Canada', 'Home', 'No memo', '2009-01-12 21:18:00', 49.283588, -123.126373);"
       "INSERT INTO point_tag (point_id, tag_id) VALUES (1, 1);"
		   "INSERT INTO point_tag (point_id, tag_id) VALUES (1, 2);"
		   "UPDATE sync_status_and_version SET version = 5;"
    ];
		DLog(@"Database migrated to v5.");
	}
	
	if(version < 6) {
		DLog(@"Database migrating to v6...");
		[db executeStatements:
      @"CREATE TABLE attachment (id INTEGER PRIMARY KEY, point_id INTEGER, friendly_name TEXT, kind TEXT, memo TEXT, file_name TEXT, recorded_at DATETIME);"
       "UPDATE sync_status_and_version SET version = 6;"
    ];
		DLog(@"Database migrated to v6.");
	}
}


@end
