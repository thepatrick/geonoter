//
//  SQLRow.m
//  SQLite Test
//
//  Created by Dustin Mierau on Tue Apr 02 2002.
//  Copyright (c) 2002 Blackhole Media, Inc. All rights reserved.
//

#import "SQLDatabase.h"
#import "SQLDatabasePrivate.h"
#import "NSDateJSON.h"

@interface SQLRow()
{
    char**	mRowData;
    char**	mColumns;
}
@end

@implementation SQLRow

- (id)initWithColumns:(char**)inColumns rowData:(char**)inRowData columns:(int)inColumnCount
{
    if (self = [super init]) {
        mRowData = inRowData;
        mColumns = inColumns;
        self.columnCount = inColumnCount;
    }
	return self;
}

- (id)init
{
    if (self = [super init]) {	
        mRowData = NULL;
        mColumns = NULL;
        self.columnCount = 0;
    }
	return self;
}

#pragma mark -

- (NSString*)nameOfColumnAtIndex:(int)inIndex
{
    if( inIndex >= self.columnCount || ![self valid] )
        return nil;
    
    return [NSString stringWithCString:mColumns[inIndex] encoding:NSUTF8StringEncoding];
}

#pragma mark -

- (NSInteger)integerForColumn:(NSString*)inColumnName
{
	return [[self stringForColumn:inColumnName] integerValue];
}

- (NSInteger)integerForColumnAtIndex:(int)inIndex
{
	return [[self stringForColumnAtIndex:inIndex] integerValue];
}

- (NSString*)stringForColumn:(NSString*)inColumnName
{
	int index;
	
	if( ![self valid] )
		return nil;
	
	for( index = 0; index < self.columnCount; index++ )
		if( strcmp( mColumns[ index ], [inColumnName cStringUsingEncoding:NSUTF8StringEncoding] ) == 0 )
			break;
	
	return [self stringForColumnAtIndex:index];
}

- (NSString*)stringForColumnAtIndex:(int)inIndex
{
	if( inIndex >= self.columnCount || ![self valid] || mRowData[ inIndex ] == nil)
		return nil;
	
	return [NSString stringWithCString:mRowData[ inIndex ] encoding:NSUTF8StringEncoding];
}

- (NSDate*)dateForColumn:(NSString*)inColumnName
{
	NSString *colValue = [self stringForColumn:inColumnName];
	return [NSDate pqg_dateWithSQLString:colValue];
}

#pragma mark -

- (NSString*)description
{
	NSMutableString*	string = [NSMutableString string];
	int					column;
	
	for( column = 0; column < self.columnCount; column++ )
	{
		if( column ) [string appendString:@" | "];
		[string appendFormat:@"%s", mRowData[ column ]];
	}
	
	return string;
}

#pragma mark -

- (BOOL)valid
{
	return ( mRowData != NULL && mColumns != NULL && self.columnCount > 0 );
}

@end
