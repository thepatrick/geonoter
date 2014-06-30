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

@interface GNPoint : NSObject {
	
	BOOL dirty;
	BOOL hydrated;
	
	UIBackgroundTaskIdentifier bgTask;
	
	id populateDelegate;
	
	void (^completionCallback)();
	
}

@property (nonatomic, copy) NSNumber *dbId;
@property (nonatomic, assign) NSInteger tripId;
@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *memo;
@property (nonatomic, copy) NSDate *recordedAt;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

@property (nonatomic, weak) PersistStore *store;


+ (instancetype)point;

+ (instancetype)pointWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;
- (instancetype)initWithPrimaryKey:(NSInteger)theID andStore:(PersistStore*)newStore;

- (instancetype)hydrate;
- (void)dehydrate;
- (void)save;

- (NSArray*)tags;
- (void)setTags:(NSArray*)newTags;

- (NSArray*)attachments;
- (GNAttachment*)addAttachment:(NSData*)attachment withExtension:(NSString*)extension;

- (void)determineDefaultName:(NSString*)locationName;

- (void)setupAsNewItem:(void (^)())completionHandler;

@end
