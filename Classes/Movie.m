//
//  Movie.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 12/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//


#import "SQLDatabase.h"
#import "PersistStore.h"
#import "Movie.h"

#define kIdElementName @"id"
#define kTitleElementName @"title"
#define kScoreElementName @"score"
#define kBlurayElementName @"bluray"
#define kDVD1ElementName @"dvd1"
#define kDVD2ElementName @"dvd2"
#define kDVD4ElementName @"dvd4"
#define kUpdatedAtElementName @"updatedat"
#define kThoughtsElementName @"thoughts"
#define kSeenItElementName @"seenit"
#define kSeenOnElementName @"seenon"


@implementation Movie

@synthesize table;
@synthesize title = _title;
@synthesize score = _score;
@synthesize bluray;
@synthesize dvd1;
@synthesize dvd2;
@synthesize dvd4;
@synthesize dbId;
@synthesize autoSetUpdatedAt;
@synthesize updatedAt;
@synthesize thoughts;
@synthesize seenOn;
@synthesize seenIt;
@synthesize store;

+movie
{
	return [[[self alloc] init] autorelease];
}

+movieWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore
{
	return [[[self alloc] initWithPrimaryKey:theID andStore:newStore] autorelease];
}

-init
{
	if(self = [super init]) {
		self.autoSetUpdatedAt = NO;
		dirty = NO;
		hydrated = NO;
		self.table = @"movie";
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
		self.table = @"movie";
	}
	return self;
}


-(void)hydrate
{
	if(self.dbId == nil || hydrated) {
		return; // we're not going to hydrate in this situation, it's unncessary!
	}
	
	SQLResult *res = [store.db performQueryWithFormat:@"SELECT * FROM %@ WHERE id = %d", table, [self.dbId integerValue]];
	if([res rowCount] == 0) {
		NSLog(@"Didn't hydrate because the select returned 0 results, sql was %@", [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = %@", table, self.dbId]);
		return; // bugger.
	}
	
	SQLRow *row = [res rowAtIndex:0];
	_title = [[row stringForColumn:@"title"] retain];
	_score = [[NSNumber numberWithInteger:[row integerForColumn:@"score"]] retain];
	bluray = [row integerForColumn:@"bluray"];
	dvd1 = [row integerForColumn:@"dvd1"];
	dvd2 = [row integerForColumn:@"dvd2"];
	dvd4 = [row integerForColumn:@"dvd4"];
	updatedAt = [[NSDate dateWithString:[row stringForColumn:@"updated_at"]] retain];
	thoughts = [[row stringForColumn:@"thoughts"] retain];
	seenIt = [row integerForColumn:@"seenit"];
	seenOn = [[NSDate dateWithString:[row stringForColumn:@"seenon"]] retain];
	
	autoSetUpdatedAt = YES;
	hydrated = YES;
}


-(void)dehydrate
{
	if(!hydrated) return; // no point wasting time

	if(self.dbId == nil) {
		return; // we're not going to dehydrate in this situation, it's unpossible!
	}
	
	[self save];
	
	[_title release];
	_title = nil;
	[_score release];
	_score = nil;
	[updatedAt release];
	updatedAt = nil;
	[thoughts release];
	thoughts = nil;
	[seenOn release];
	seenOn = nil;
	
	hydrated = NO;
}

-(void)save
{
	if(self.dbId == nil) {
		return; // we're not going to dehydrate in this situation, it's unpossible!
	}
	if(dirty) {
		self.updatedAt = [NSDate date];
		[store insertOrUpdateTrip:self];
		dirty = NO;
	}	
}

-(void)saveForNew
{
	self.updatedAt = [NSDate date];
	[store insertOrUpdateTrip:self];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@> ID: '%@'. Title: '%@'. Score: '%@'.", [self class], self.dbId, self.title, self.score];
}

- (void)setTitle:(NSString *)newTitle
{
    [_title release];
    _title = [newTitle copy];
	if(autoSetUpdatedAt) {
		dirty = YES;
	}
}

- (void)setThoughts:(NSString *)newThoughts
{
    [thoughts release];
    thoughts = [newThoughts copy];
	if(autoSetUpdatedAt) {
		dirty = YES;
	}
}


- (void)setScore:(NSNumber *)newScore
{
    [_score release];
    _score = [newScore copy];
	if(autoSetUpdatedAt) {
		dirty = YES;
	}
}

- (void)setBluray:(BOOL)newValue
{
	bluray = newValue;
	if(autoSetUpdatedAt) {
		dirty = YES;
	}
}

- (void)setDvd1:(BOOL)newValue
{
	dvd1 = newValue;
	if(autoSetUpdatedAt) {
		dirty = YES;
	}
}

- (void)setDvd2:(BOOL)newValue
{
	dvd2 = newValue;
	if(autoSetUpdatedAt) {
		dirty = YES;
	}
}
- (void)setDvd4:(BOOL)newValue
{
	dvd4 = newValue;
	if(autoSetUpdatedAt) {
		dirty = YES;
	}
}

- (void)setSeenIt:(BOOL)newValue
{
	seenIt = newValue;
	if(autoSetUpdatedAt) {
		dirty = YES;
	}
}

@end
