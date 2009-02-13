//
//  PersistStore.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 14/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SQLDatabase;
@class Movie;
@class Trip;
@class Tag;
@class GNPoint;

@interface PersistStore : NSObject {

	SQLDatabase *db;
	
	NSMutableDictionary *centralTripStore;
	NSMutableDictionary *centralTagStore;
	NSMutableDictionary *centralPointStore;
	
	NSMutableArray *_inPlayMovieFetch;

	BOOL dbIsOpen;
	
	NSLock *dbLock;
}

@property (nonatomic, retain) SQLDatabase *db;

+storeWithFile:(NSString*)file;

-(BOOL)openDatabase:(NSString *)fileName;
-(void)closeDatabase;
-(void)migrateFrom:(NSInteger)version;

-(void)tellCacheToDehydrate;
-(void)tellCacheToSave;

#pragma mark -
#pragma mark Trips
-(BOOL)insertOrUpdateTrip:(Trip*)trip;
-(void)deleteTripFromStore:(NSInteger)tripId;
-(void)removeTripFromCache:(NSInteger)tripId;
-(NSMutableArray*)getTripsWithConditions:(NSString*)conditions andSort:(NSString*)sort;
-(NSMutableArray*)getAllTrips;
-(Trip*)getTrip:(NSInteger)tripId;

#pragma mark -
#pragma mark Tags
-(BOOL)insertOrUpdateTag:(Tag*)tag;
-(void)deleteTagFromStore:(NSInteger)tagId;
-(void)removeTagFromCache:(NSInteger)tagId;
-(NSMutableArray*)getTagsWithConditions:(NSString*)conditions andSort:(NSString*)sort;
-(NSMutableArray*)getAllTags;
-(Tag*)getTag:(NSInteger)tagId;


#pragma mark -
#pragma mark Points
-(BOOL)insertOrUpdatePoint:(GNPoint*)point;
-(void)deletePointFromStore:(NSInteger)pointId;
-(void)removePointFromCache:(NSInteger)pointId;
-(NSMutableArray*)getPointsWithConditions:(NSString*)conditions andSort:(NSString*)sort;
-(NSMutableArray*)getAllPoints;
-(GNPoint*)getPoint:(NSInteger)pointId;

@end
