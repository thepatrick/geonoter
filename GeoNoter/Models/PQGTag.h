//
//  PQGTag.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 20/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

#import "FCModel.h"

@interface PQGTag : FCModel

@property (nonatomic) int64_t id;
@property (nonatomic, copy) NSString *name;

@property (nonatomic, readonly) NSArray *points;

+(NSArray*)getTagsWithConditions:(NSString*)conditions andSort:(NSString*)sort;

@end
