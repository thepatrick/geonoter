//
//  PQGTag.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 20/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

#import "PersistStore.h"
#import "PQGTag.h"

@implementation PQGTag

+ (NSArray*)allInstances {
  return [self instancesOrderedBy:@"name ASC"];
}

+(NSArray*)getTagsWithConditions:(NSString*)conditions andSort:(NSString*)sort
{
  NSString *sql = [NSString stringWithFormat:@"%@ ORDER BY %@",
                          (conditions != nil ? [@"WHERE " stringByAppendingString:conditions] : @""),
                          (sort != nil ? sort : @"name ASC")];
  return [self instancesWhere:sql];
}

-(NSArray*)points {
  return [PQGPoint instancesWhere:@"id IN (SELECT point_id FROM point_tag WHERE tag_id = ?) ORDER BY name ASC", self.id];
}

@end
