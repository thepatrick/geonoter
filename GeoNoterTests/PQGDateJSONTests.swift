//
//  PQGDateJSONTests.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 15/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit
import XCTest

class PQGDateJSONTests: XCTestCase {

  let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
  
  let allComponents = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit |
    NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit
  
  override func setUp() {
    super.setUp()
    
    calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testDateWithJSONString() {
    let jsonDate = "2014-04-24T12:35:44Z"
    let asDate = NSDate.pqg_dateWithJSONString(jsonDate)
    
    XCTAssertNotNil(asDate, "Date not converted from \(jsonDate)")
    
    let comps = calendar.components(allComponents, fromDate: asDate)

    XCTAssertNotNil(comps, "components(fromDate:) returned nil")
    XCTAssertEqual(comps.year, 2014, "Year is incorrect")
    XCTAssertEqual(comps.month, 4, "Month is incorrect")
    XCTAssertEqual(comps.day, 24, "Day is incorrect")
    
    XCTAssertEqual(comps.hour, 12, "Hour is incorrect")
    XCTAssertEqual(comps.minute, 35, "Minute is incorrect")
    XCTAssertEqual(comps.second, 44, "Second is incorrect")
  }
  
  func testJSONStringFromDate() {
    let dateComponents = NSDateComponents()
    dateComponents.year   = 2014
    dateComponents.month  = 4
    dateComponents.day    = 24
    dateComponents.hour   = 12
    dateComponents.minute = 35
    dateComponents.second = 44
    
    let asDate = calendar.dateFromComponents(dateComponents)
    XCTAssertNotNil(asDate, "dateFromComponents is nil")
    
    let asString = asDate.pqg_jsonString() as String
    XCTAssertEqual(asString, "2014-04-24T12:35:44Z", "String not generated correctly")
  }
  
  func testDateWithSQLString() {
    let sqlDate = "2014-04-24 12:35:44"
    let asDate = NSDate.pqg_dateWithSQLString(sqlDate)
    
    XCTAssertNotNil(asDate, "Date not converted from \(sqlDate)")
    
    let comps = calendar.components(allComponents, fromDate: asDate)
    
    XCTAssertNotNil(comps, "components(fromDate:) returned nil")
    XCTAssertEqual(comps.year, 2014, "Year is incorrect")
    XCTAssertEqual(comps.month, 4, "Month is incorrect")
    XCTAssertEqual(comps.day, 24, "Day is incorrect")
    
    XCTAssertEqual(comps.hour, 12, "Hour is incorrect")
    XCTAssertEqual(comps.minute, 35, "Minute is incorrect")
    XCTAssertEqual(comps.second, 44, "Second is incorrect")
  }
  
  func testSQLStringFromDate() {
    let dateComponents = NSDateComponents()
    dateComponents.year   = 2014
    dateComponents.month  = 4
    dateComponents.day    = 24
    dateComponents.hour   = 12
    dateComponents.minute = 35
    dateComponents.second = 44
    
    let asDate = calendar.dateFromComponents(dateComponents)
    XCTAssertNotNil(asDate, "dateFromComponents is nil")
    
    let asString = asDate.pqg_sqlDateString() as String
    XCTAssertEqual(asString, "2014-04-24 12:35:44", "String not generated correctly")
  }

}
