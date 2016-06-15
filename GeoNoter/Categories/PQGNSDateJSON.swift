//
//  PQGNSDateJSON.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 2/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

public extension Date {
  
  private static func pqg_JSONDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(localeIdentifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    formatter.timeZone = TimeZone(forSecondsFromGMT: 0)
    return formatter
  }
  
  static func pqg_dateWithJSONString(_ jsonDate: String) -> Date {
    return pqg_JSONDateFormatter().date(from: jsonDate)!
  }
  
  func pqg_jsonString() -> String {
    return Date.pqg_JSONDateFormatter().string(from: self)
  }
  
}
