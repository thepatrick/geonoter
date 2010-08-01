//
//  NSStringUUID.m
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 09-06-20.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "NSStringUUID.h"


@implementation NSString(UUID)

+stringWithUUID {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
	//get the string representation of the UUID
	NSString	*uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [uuidString autorelease];
}

@end
