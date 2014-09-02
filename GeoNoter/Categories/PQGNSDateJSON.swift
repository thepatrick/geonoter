//
//  PQGNSDateJSON.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 2/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

public extension NSDate {
  
  private class func pqg_JSONDateFormatter() -> NSDateFormatter {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    return formatter
  }
  
  class func pqg_dateWithJSONString(jsonDate: String) -> NSDate {
    return pqg_JSONDateFormatter().dateFromString(jsonDate)!
  }
  
  func pqg_jsonString() -> String {
    return NSDate.pqg_JSONDateFormatter().stringFromDate(self)
  }
  
}