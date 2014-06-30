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
  
}

@property (nonatomic, copy) NSNumber *dbId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDate *start;
@property (nonatomic, copy) NSDate *end;
@property (nonatomic, weak) PersistStore *store;

+ (instancetype)trip;

+ (instancetype)tripWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore;

- (instancetype)initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore *)newStore;

- (Trip*)hydrate;
- (void)dehydrate;
- (void)save;
- (void)saveForNew;

@end
