//
//  Point.h
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 12/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class PersistStore;

@interface GNPoint : NSObject<MKReverseGeocoderDelegate> {
	
	BOOL dirty;
	BOOL hydrated;
	
	NSNumber *dbId;
	
	// trip_id, friendly_name, name, memo, recorded_at, latitude, longitude
	
	NSInteger tripId;
	NSString *friendlyName;
	NSString *name;
	NSString *memo;
	NSDate *recordedAt;
	CGFloat latitude;
	CGFloat longitude;
	
	PersistStore *store;
	
	UIBackgroundTaskIdentifier bgTask;
	
	id populateDelegate;
	
	void (^completionCallback)();
	
}

@property (copy) NSNumber *dbId;
@property (assign) NSInteger tripId;
@property (copy) NSString *friendlyName;
@property (copy) NSString *name;
@property (copy) NSString *memo;
@property (copy) NSDate *recordedAt;
@property (assign) CGFloat latitude;
@property (assign) CGFloat longitude;

@property (retain) PersistStore *store;


+point;

+pointWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;
-initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;

-hydrate;
-(void)dehydrate;
-(void)save;

-(NSArray*)tags;
-(void)setTags:(NSArray*)newTags;

-(NSArray*)attachments;

-(GNPoint*)storePointData;

-(void)determineDefaultName:(NSString*)locationName;

-(void)geocodeWithCompletionBlock:(void (^)())completion;

@end
