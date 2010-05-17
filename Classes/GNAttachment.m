//
//  GNAttachment.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 18/02/09.
//  Copyright 2009 Petromedia Ltd.. All rights reserved.
//

#import "SQLDatabase.h"
#import "PersistStore.h"
#import "GNAttachment.h"
#import "GeoNoterAppDelegate.h"


@implementation GNAttachment


@synthesize dbId;
@synthesize pointId;
@synthesize friendlyName;
@synthesize kind;
@synthesize memo;
@synthesize fileName;
@synthesize recordedAt;
@synthesize store;

+attachment
{
	return [[[self alloc] init] autorelease];
}

+attachmentWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore
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
	return [NSString stringWithFormat:@"<%@> ID: '%@'. File Name: '%@'. Name: '%@'", [self class], self.dbId, self.fileName, self.friendlyName];
}

-hydrate
{
	if(self.dbId == nil || hydrated) {
		return self; // we're not going to hydrate in this situation, it's unncessary!
	}
	
	SQLResult *res = [store.db performQueryWithFormat:@"SELECT * FROM attachment WHERE id = %d", [self.dbId integerValue]];
	if([res rowCount] == 0) {
		NSLog(@"Didn't hydrate because the select returned 0 results, sql was %@", [NSString stringWithFormat:@"SELECT * FROM point WHERE id = %@", self.dbId]);
		return self; // bugger.
	}
	
	SQLRow *row = [res rowAtIndex:0];
	
	self.pointId = [[row stringForColumn:@"point_id"] integerValue];
	self.friendlyName = [row stringForColumn:@"friendly_name"];
	self.kind = [row stringForColumn:@"kind"];	
	self.memo = [row stringForColumn:@"memo"];	
	self.fileName = [row stringForColumn:@"file_name"];
	self.recordedAt = [row dateForColumn:@"recorded_at"];
	
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
	
	[fileName release];
	fileName = nil;
	[friendlyName release];
	friendlyName = nil;
	[kind release];
	kind = nil;
	[memo release];
	memo = nil;
	[recordedAt release];
	recordedAt = nil;
	
	hydrated = NO;
}

-(void)save
{
	if(dirty) {
		[store insertOrUpdateAttachment:self];
		dirty = NO;
	}	
}

-(void)setPointId:(NSInteger)newValue
{
	pointId = newValue;
	dirty = YES;	
}

-(void)setFriendlyName:(NSString*)newValue
{
	[friendlyName release];
	friendlyName = [newValue copy];
	dirty = YES;	
}

-(void)setFileName:(NSString*)newValue
{
	[fileName release];
	fileName = [newValue copy];
	dirty = YES;	
}

-(void)setKind:(NSString*)newValue
{
	[kind release];
	kind = [newValue copy];
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

-(NSString*)filesystemPath {
	NSString *base = [(GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate] attachmentsDirectory];
	return [base stringByAppendingPathComponent:self.fileName];	
}

-(void)deleteAttachment {
	[store deleteAttachmentFromStore:[self.dbId integerValue]];
	[[NSFileManager defaultManager] removeItemAtPath:[self filesystemPath] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[[self filesystemPath] stringByAppendingString:@".cached.jpg"] error:nil];
}

@end
