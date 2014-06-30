//
//  SQLResult.m
//  SQLite Test
//
//  Created by Dustin Mierau on Tue Apr 02 2002.
//  Copyright (c) 2002 Blackhole Media, Inc. All rights reserved.
//

#import "SQLDatabase.h"
#import "SQLDatabasePrivate.h"

@interface SQLResult()
{
    char**	mTable;
}
@end

@implementation SQLResult

#pragma mark -

- (id)initWithTable:(char**)inTable rows:(int)inRows columns:(int)inColumns
{
    if(self = [super init]) {
        mTable = inTable;
        self.rowCount = inRows;
        self.columnCount = inColumns;
    }
	return self;
}

- (void)dealloc
{
    if (mTable) {
		sqlite3_free_table( mTable );
		mTable = NULL;
	}
}

#pragma mark -

- (SQLRow*)rowAtIndex:(NSInteger)inIndex
{
    if (inIndex >= self.rowCount) {
		return nil;
    }
	
	return [[SQLRow alloc] initWithColumns:mTable rowData:( mTable + ( ( inIndex + 1 ) * self.columnCount ) ) columns:self.columnCount];
}

- (NSEnumerator*)rowEnumerator
{
	return [[SQLRowEnumerator alloc] initWithResult:self];
}

@end

#pragma mark -

@interface SQLRowEnumerator()

@property SQLResult *result;
@property NSInteger position;

@end

@implementation SQLRowEnumerator

- (id)initWithResult:(SQLResult*)inResult
{
	if( ![super init] )
		return nil;
    
    self.result = inResult;
    
	self.position = 0;
	
	return self;
}

- (id)nextObject
{
    if( self.position >= self.result.rowCount) {
		return nil;
    }
    return [self.result rowAtIndex:self.position++];
}

@end