//
//  NSStringUUID.m
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 09-06-20.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "NSStringUUID.h"


@implementation NSString(UUID)

+(NSString*)stringWithUUID {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
	//get the string representation of the UUID
    return [NSString stringWithString:(NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj))];
}

@end
