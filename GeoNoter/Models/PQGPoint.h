//
//  PQGPoint.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 20/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

#import "FCModel.h"
#import <MapKit/MapKit.h>

@class PQGTag;
@class PQGAttachment;

@interface PQGPoint : FCModel

@property (nonatomic) int64_t id;

@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *memo;
@property (nonatomic, copy) NSDate *recordedAt;

@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

- (NSArray*)tags;
- (void)addTag:(PQGTag*)tag;
- (void)removeTag:(PQGTag*)tag;

- (NSArray*)attachments;
- (PQGAttachment*)addAttachment:(NSData*)attachment withExtension:(NSString*)extension;

- (void)determineDefaultName:(NSString*)locationName;

- (void)setupAsNewItem:(void (^)())completionHandler;

@end
