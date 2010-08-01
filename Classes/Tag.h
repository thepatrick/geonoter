//
//  Tag.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 09-01-11.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PersistStore;

@interface Tag : NSObject {

	BOOL dirty;
	BOOL hydrated;
	
	NSNumber *dbId;
	NSString *name;
	
	PersistStore *store;
	
}

@property (copy) NSNumber *dbId;
@property (copy) NSString *name;
@property (retain) PersistStore *store;

+tag;

+tagWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;

-initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;

-(void)destroy;
-(Tag*)hydrate;
-(void)dehydrate;
-(void)save;
-(void)saveForNew;

-(NSArray*)points;


@end
