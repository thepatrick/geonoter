//
//  PQGAttachment.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 20/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

#import "FCModel.h"

@interface PQGAttachment : FCModel

@property (nonatomic)           int64_t id;
@property (nonatomic, assign)   int64_t  pointId;
@property (nonatomic, copy)     NSString *friendlyName;
@property (nonatomic, copy)     NSString *kind;
@property (nonatomic, copy)     NSString *memo;
@property (nonatomic, copy)     NSString *fileName;
@property (nonatomic, copy)     NSDate   *recordedAt;

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSString *filesystemPath;

- (UIImage*)loadCachedImageForSize:(NSInteger)largestSide;


@end
