//
//  Point.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 12/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import "SQLDatabase.h"
#import "PersistStore.h"
#import "GNPoint.h"
#import "Tag.h"

@implementation GNPoint

@synthesize dbId;
@synthesize tripId;
@synthesize friendlyName;
@synthesize name;
@synthesize memo;
@synthesize recordedAt;
@synthesize latitude;
@synthesize longitude;
@synthesize store;

+point
{
	return [[[self alloc] init] autorelease];
}

+pointWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore
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
		dbId = [[NSNumber numberWithInteger:theID] retain];
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

-hydrate
{
	if(self.dbId == nil || hydrated) {
		return self; // we're not going to hydrate in this situation, it's unncessary!
	}
	
	SQLResult *res = [store.db performQueryWithFormat:@"SELECT * FROM point WHERE id = %d", [self.dbId integerValue]];
	if([res rowCount] == 0) {
		NSLog(@"Didn't hydrate because the select returned 0 results, sql was %@", [NSString stringWithFormat:@"SELECT * FROM point WHERE id = %@", self.dbId]);
		return self; // bugger.
	}
	
	SQLRow *row = [res rowAtIndex:0];
	
	self.tripId = [[row stringForColumn:@"name"] integerValue];
	self.friendlyName = [row stringForColumn:@"friendly_name"];
	self.name = [row stringForColumn:@"name"];
	self.memo = [row stringForColumn:@"memo"];	
	self.recordedAt = [row dateForColumn:@"recorded_at"];
	self.latitude = [[row stringForColumn:@"latitude"] floatValue];
	self.longitude = [[row stringForColumn:@"longitude"] floatValue];
	
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
	
	[friendlyName release];
	friendlyName = nil;
	[name release];
	name = nil;
	[memo release];
	memo = nil;
	[recordedAt release];
	recordedAt = nil;
	
	hydrated = NO;
}

-(void)save
{
	if(dirty) {
		[store insertOrUpdatePoint:self];
		dirty = NO;
	}	
}


-(void)setTripId:(NSInteger)newValue
{
	tripId = newValue;
	dirty = YES;	
}

-(void)setFriendlyName:(NSString*)newValue
{
	[friendlyName release];
	friendlyName = [newValue copy];
	dirty = YES;	
}

-(void)setName:(NSString*)newValue
{
	[name release];
	name = [newValue copy];
	dirty = YES;	
}

-(void)setMemo:(NSString*)newValue
{
	[memo release];
	memo = [newValue copy];
	dirty = YES;	
}

-(void)setRecordedAt:(NSDate*)newValue
{
	[recordedAt release];
	recordedAt = [newValue copy];
	dirty = YES;	
}

-(void)setLatitude:(CGFloat)newValue
{
	latitude = newValue;
	dirty = YES;	
}

-(void)setLongitude:(CGFloat)newValue
{
	longitude = newValue;
	dirty = YES;	
}

-(NSArray*)tags {
	NSString *cond = [NSString stringWithFormat:@"id IN (select tag_id FROM point_tag WHERE point_id = %@)", self.dbId];
	return [store getTagsWithConditions:cond andSort:@"name ASC"];
}


-(void)setTags:(NSArray*)newTags {
	[store removeTagFromPoint:[self.dbId integerValue]];
	for(Tag *t in newTags) {
		[store addTag:[t.dbId integerValue] toPoint:[self.dbId integerValue]];
	}
}

@end
