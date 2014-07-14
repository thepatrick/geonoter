//
//  SQLDatabase.m
//  SQLite Test
//
//  Created by Dustin Mierau on Tue Apr 02 2002.
//  Copyright (c) 2002 Blackhole Media, Inc. All rights reserved.
//

#import "SQLDatabase.h"
#import "SQLDatabasePrivate.h"

@interface SQLDatabase()
{
    sqlite3*		mDatabase;
}

@property (copy, nonatomic) NSString *path;
@end

@implementation SQLDatabase

+ (instancetype)databaseWithFile:(NSString*)inPath
{
	return [[SQLDatabase alloc] initWithFile:inPath];
}

#pragma mark -

- (instancetype)initWithFile:(NSString*)inPath
{
	if( ![super init] )
		return nil;
    
    self.path = inPath;
	mDatabase = NULL;
	
	return self;
}

- (instancetype)init
{
	if( ![super init] )
		return nil;
    
	mDatabase = NULL;
	
	return self;
}

- (void)dealloc
{
	NSLog(@"SQLDatabase going away.");
	[self close];
}

#pragma mark -

- (BOOL)open
{
    sqlite3_open( [self.path fileSystemRepresentation], &mDatabase );
	if( !mDatabase )
	{
		return NO;
	}
	
	return YES;
}

- (void)close
{
	if( !mDatabase )
		return;
	sqlite3_close( mDatabase );
	mDatabase = NULL;
}

#pragma mark -

+ (NSString*)prepareStringForQuery:(NSString*)inString
{
	NSMutableString*	string;
	NSRange				range = NSMakeRange( 0, [inString length] );
	NSRange				subRange;
	
	if(inString == nil) return nil; // just don't try.
	
	subRange = [inString rangeOfString:@"'" options:NSLiteralSearch range:range];
	if( subRange.location == NSNotFound )
		return inString;
	
	string = [NSMutableString stringWithString:inString];
	for( ; subRange.location != NSNotFound && range.length > 0;  )
	{
		subRange = [string rangeOfString:@"'" options:NSLiteralSearch range:range];
		if( subRange.location != NSNotFound )
			[string replaceCharactersInRange:subRange withString:@"''"];
		
		range.location = subRange.location + 2;
		range.length = ( [string length] < range.location ) ? 0 : ( [string length] - range.location );
	}
	
	return string;
}

- (SQLResult*)performQuery:(NSString*)inQuery
{
	SQLResult*	sqlResult = nil;
	char**		results;
	int			result;
	int			columns;
	int			rows;
	
	if( !mDatabase )
		return nil;

  result = sqlite3_get_table( mDatabase, [inQuery cStringUsingEncoding:NSUTF8StringEncoding], &results, &rows, &columns, NULL );
  
  if (result != SQLITE_OK) {
    const char * err = sqlite3_errmsg(mDatabase);
    NSString *str = [NSString stringWithCString:err encoding:NSUTF8StringEncoding];
    NSLog(@"SQLITE said %@ NOT ok! It was: %@", inQuery, str);
		sqlite3_free_table( results );
		return nil;
  }
	
	sqlResult = [[SQLResult alloc] initWithTable:results rows:rows columns:columns];
  
	if( !sqlResult )
		sqlite3_free_table( results );
	
	return sqlResult;
}

- (NSArray*)performQueries:(NSArray*)queries
{
    NSMutableArray *response = [NSMutableArray arrayWithCapacity:queries.count];
    for (NSString *query in queries) {
        [response addObject:[self performQuery:query]];
    }
    return [NSArray arrayWithArray:response];
}

- (SQLResult*)performQueryWithFormat:(NSString*)inFormat, ...
{
	SQLResult*	sqlResult = nil;
	NSString*	query = nil;
	va_list		arguments;
	
  if (inFormat == nil) {
		return nil;
  }
	
	va_start(arguments, inFormat);
	
	query = [[NSString alloc] initWithFormat:inFormat arguments:arguments];
	sqlResult = [self performQuery:query];
	
	va_end(arguments);
	
	return sqlResult;
}

@end
