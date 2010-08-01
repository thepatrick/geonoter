//
//  Trip.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PersistStore;

@interface Trip : NSObject {
	
	BOOL dirty;
	BOOL hydrated;
	
	NSNumber *dbId;
	NSString *name;
	NSDate *start;
	NSDate *end;
	
	PersistStore *store;
	
}

@property (copy) NSNumber *dbId;
@property (copy) NSString *name;
@property (copy) NSDate *start;
@property (copy) NSDate *end;
@property (retain) PersistStore *store;

+trip;

+tripWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore;

-initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore;

-(Trip*)hydrate;
-(void)dehydrate;
-(void)save;
-(void)saveForNew;

@end
