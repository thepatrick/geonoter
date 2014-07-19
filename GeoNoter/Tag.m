//
//  Tag.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 09-01-11.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "SQLDatabase.h"
#import "PersistStore.h"
#import "Tag.h"


@implementation Tag

+ (instancetype)tag
{
	return [[self alloc] init];
}

+tagWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore
{
	return [[self alloc] initWithPrimaryKey:theID andStore:newStore];
}

-init
{
	if(self = [super init]) {
		dirty = NO;
		hydrated = NO;
	}
	return self;
}

- (instancetype)initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore
{
	if(self = [super init]) {
    self.dbId = @(theID);
    self.store = newStore;
		hydrated = NO;
		dirty = NO;
	}
	return self;
}

- (instancetype)initWithName:(NSString*)name
{
  if(self = [self init]) {
    self.name = name;
  }
  return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@> ID: '%@'. Name: '%@'.", [self class], self.dbId, self.name];
}

- (void)destroy {
	[self.store deleteTagFromStore:[self.dbId integerValue]];
}

- (Tag*)hydrate
{
	if(self.dbId == nil || hydrated) {
		return self; // we're not going to hydrate in this situation, it's unncessary!
	}
	
	SQLResult *res = [self.store.db performQueryWithFormat:@"SELECT * FROM tag WHERE id = %d", [self.dbId integerValue]];
	if([res rowCount] == 0) {
		NSLog(@"Didn't hydrate because the select returned 0 results, sql was %@", [NSString stringWithFormat:@"SELECT * FROM tag WHERE id = %@", self.dbId]);
		return self; // bugger.
	}
	
	SQLRow *row = [res rowAtIndex:0];
	
	_name = [[row stringForColumn:@"name"] copy];
	
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
  
	_name = nil;
	
	hydrated = NO;
}

-(void)save
{
	if(self.dbId == nil) {
		return; // we're not going to dehydrate in this situation, it's unpossible!
	}
	if(dirty) {
		[self.store insertOrUpdateTag:self];
		dirty = NO;
	}	
}
-(void)saveForNew
{
	NSLog(@"saveForNew!");
	[self.store insertOrUpdateTag:self];
	dirty = NO;
}

-(void)setName:(NSString*)newName
{
	_name = [newName copy];
	dirty = YES;	
}

-(NSArray*)points {
	NSString *cond = [NSString stringWithFormat:@"id IN (SELECT point_id FROM point_tag WHERE tag_id = %@)", self.dbId];
	return [self.store getPointsWithConditions:cond andSort:@"name ASC"];
}

@end
