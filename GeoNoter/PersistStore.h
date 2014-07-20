//
//  PersistStore.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 14/03/08.
//  Copyright 2008-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FCModel.h"
#import "PQGTag.h"
#import "PQGPoint.h"
#import "PQGAttachment.h"

@interface PersistStore : NSObject

# pragma mark - Helpers
+ (NSString*)pathForResource:(NSString*)path;
+ (NSString*)attachmentsDirectory;
+ (NSURL*)pathForCacheResource:(NSString*)path;
+ (NSURL*)attachmentsCacheDirectory;
+ (NSURL*)attachmentCacheURL:(NSString*)attachmentName;

# pragma mark - Store API

+(void)openDatabase:(NSString *)fileName;


@end
