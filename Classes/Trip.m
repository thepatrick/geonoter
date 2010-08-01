//
//  Trip.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "SQLDatabase.h"
#import "PersistStore.h"
#import "Trip.h"
#import "NSDateJson.h"


@implementation Trip

@synthesize dbId;
@synthesize name;
@synthesize start;
@synthesize end;
@synthesize store;

+trip
{
	return [[[self alloc] init] autorelease];
}

+tripWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore
{
	return [[[self alloc] initWithPrimaryKey:theID andStore:newStore] autorelease];
}

-init
{
	if(self = [super init]) {
		dirty = NO;
		hydrated = NO;
	}
	return self;
}

-initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore
{
	if(self = [super init]) {
		self.dbId = [NSNumber numberWithInteger:theID];
		store = [newStore retain];
		hydrated = NO;
		dirty = NO;
}
	return self;
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@> ID: '%@'. Name: '%@'.", [self class], self.dbId, self.name];
}

-(Trip*)hydrate
{
	if(self.dbId == nil || hydrated) {
		return self; // we're not going to hydrate in this situation, it's unncessary!
	}
	
	SQLResult *res = [store.db performQueryWithFormat:@"SELECT * FROM trip WHERE id = %d", [self.dbId integerValue]];
	if([res rowCount] == 0) {
		NSLog(@"Didn't hydrate because the select returned 0 results, sql was %@", [NSString stringWithFormat:@"SELECT * FROM trip WHERE id = %@", self.dbId]);
		return self; // bugger.
	}
	
	SQLRow *row = [res rowAtIndex:0];
	
	name = [[row stringForColumn:@"name"] retain];
	start = [[NSDate dateWithSQLString:[row stringForColumn:@"start"]] retain];
	end = [[NSDate dateWithSQLString:[row stringForColumn:@"end"]] retain];
	
	hydrated = YES;
	return self;
}

-(void)dehydrate
{
	if(!hydrated) return; // no point wasting time
	
	if(self.dbId == nil) {
		return; // we're not going to dehydrate in this situation, it's unpossible!
	}
	
	[self save];
	
	[name release];
	name = nil;
	[start release];
	start = nil;
	[end release];
	end = nil;
	
	hydrated = NO;
}

-(void)save
{
	if(self.dbId == nil) {
		return; // we're not going to dehydrate in this situation, it's unpossible!
	}
	if(dirty) {
		[store insertOrUpdateTrip:self];
		dirty = NO;
	}	
}

-(void)saveForNew
{
	
	[store insertOrUpdateTrip:self];
	dirty = NO;
}

-(void)setName:(NSString*)newName
{
	[name release];
	name = [newName copy];
	dirty = YES;	
}


-(void)setStart:(NSDate*)newStart
{
	[newStart release];
	start = [newStart copy];
	dirty = YES;	
}

-(void)setEnd:(NSDate*)newEnd
{
	[newEnd release];
	end = [newEnd copy];
	dirty = YES;	
}

@end
