//
//  NSDate+JSON.h
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 09-02-09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//
//

@interface NSDate (NSDateJSON)

+(instancetype)pqg_dateWithJSONString:(NSString*)jsonDate;
+(instancetype)pqg_dateWithSQLString:(NSString*)sqlDate;

-(NSString*)pqg_jsonString;
-(NSString*)pqg_sqlDateString;

@end
