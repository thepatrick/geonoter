//
//  NSDate+JSON.m
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 09-02-09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//
//

#import "NSDateJSON.h"


@implementation NSDate (NSDateJSON)

+(NSDateFormatter*)pqg_JSONDateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale: [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return formatter;
}

+(NSDateFormatter*)pqg_SQLDateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale: [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return formatter;
}

+(instancetype)pqg_dateWithJSONString:(NSString*)jsonDate {
    return [[NSDate pqg_JSONDateFormatter] dateFromString:jsonDate];
}


+(instancetype)pqg_dateWithSQLString:(NSString*)sqlDate {
	return [[NSDate pqg_SQLDateFormatter] dateFromString:sqlDate];
}


-(NSString*)pqg_jsonString {
	return [[NSDate pqg_JSONDateFormatter] stringFromDate:self];
}

-(NSString*)pqg_sqlDateString {
    return [[NSDate pqg_SQLDateFormatter] stringFromDate:self];
}

@end
