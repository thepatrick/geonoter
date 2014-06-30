//
//  GNAttachment.h
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 18/02/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
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
  
}


@property (nonatomic, copy) NSNumber *dbId;
@property (nonatomic, assign) NSInteger pointId;
@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *memo;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSDate *recordedAt;
@property (nonatomic, retain) PersistStore *store;

+attachment;

+attachmentWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;
-initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;

-hydrate;
-(void)dehydrate;
-(void)save;

-(NSString*)filesystemPath;

-(void)deleteAttachment;

@end
