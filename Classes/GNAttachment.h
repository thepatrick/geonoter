//
//  GNAttachment.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 18/02/09.
//  Copyright 2009 Petromedia Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PersistStore;


@interface GNAttachment : NSObject {
//id INTEGER PRIMARY KEY, 
//point_id INTEGER, 
//friendly_name TEXT, 
//kind TEXT, 
//memo TEXT, 
//recorded_at DATETIME
	
	BOOL dirty;
	BOOL hydrated;
	
	NSNumber *dbId;
	
	NSInteger pointId;
	NSString *friendlyName;
	NSString *kind;
	NSString *memo;
	NSString *fileName;
	NSDate *recordedAt;
	
	PersistStore *store;
	
}


@property (copy) NSNumber *dbId;
@property (assign) NSInteger pointId;
@property (copy) NSString *friendlyName;
@property (copy) NSString *kind;
@property (copy) NSString *memo;
@property (copy) NSString *fileName;
@property (copy) NSDate *recordedAt;
@property (retain) PersistStore *store;

+attachment;

+attachmentWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;
-initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;

-hydrate;
-(void)dehydrate;
-(void)save;

-(NSString*)filesystemPath;

-(void)deleteAttachment;

@end
