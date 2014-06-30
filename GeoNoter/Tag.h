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
	
}

@property (nonatomic, copy) NSNumber *dbId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) PersistStore *store;

+ (instancetype)tag;

+ (instancetype)tagWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;

- (instancetype)initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;

- (void)destroy;
- (Tag*)hydrate;
- (void)dehydrate;
- (void)save;
- (void)saveForNew;

- (NSArray*)points;


@end
