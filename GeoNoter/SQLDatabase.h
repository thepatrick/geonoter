//
//  SQLDatabase.h
//  An objective-c wrapper for the SQLite library
//  available at http://www.hwaci.com/sw/sqlite/
//
//  Created by Dustin Mierau on Tue Apr 02 2002.
//  Copyright (c) 2002 Blackhole Media, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@class SQLResult;
@class SQLRow;

@interface SQLDatabase : NSObject 

+ (instancetype)databaseWithFile:(NSString*)inPath;
- (instancetype)initWithFile:(NSString*)inPath;

- (BOOL)open;
- (void)close;

+ (NSString*)prepareStringForQuery:(NSString*)inString;
- (SQLResult*)performQuery:(NSString*)inQuery;
- (SQLResult*)performQueryWithFormat:(NSString*)inFormat, ...;

- (NSArray*)performQueries:(NSArray*)queries;

@end

@interface SQLResult : NSObject

@property int rowCount;
@property int columnCount;

- (SQLRow*)rowAtIndex:(NSInteger)inIndex;
- (NSEnumerator*)rowEnumerator;

@end

@interface SQLRow : NSObject

@property int columnCount;

- (double)doubleForColumn:(NSString*)inColumnName;
- (long long)longLongForColumn:(NSString*)inColumnName;
- (NSInteger)integerForColumn:(NSString*)inColumnName;
- (NSInteger)integerForColumnAtIndex:(int)inIndex;

- (NSString*)stringForColumn:(NSString*)inColumnName;
- (NSString*)stringForColumnAtIndex:(int)inIndex;

- (NSDate*)dateForColumn:(NSString*)inColumnName;

@end