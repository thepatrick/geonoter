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

  let calendar = Calendar(calendarIdentifier: .gregorian)
  
  let allComponents: Calendar.Unit = [.year, .month, .day, .hour, .minute, .second]
  
  override func setUp() {
    super.setUp()
    
    calendar!.timeZone = TimeZone(forSecondsFromGMT: 0)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testDateWithJSONString() {
    let jsonDate = "2014-04-24T12:35:44Z"
    let asDate = Date.pqg_dateWithJSONString(jsonDate)

    XCTAssertNotNil(asDate, "Date not converted from \(jsonDate)")
    
    let comps = calendar!.components(allComponents, from: asDate)

    XCTAssertNotNil(comps, "components(fromDate:) returned nil")
    XCTAssertEqual(comps.year, 2014, "Year is incorrect")
    XCTAssertEqual(comps.month, 4, "Month is incorrect")
    XCTAssertEqual(comps.day, 24, "Day is incorrect")
    
    XCTAssertEqual(comps.hour, 12, "Hour is incorrect")
    XCTAssertEqual(comps.minute, 35, "Minute is incorrect")
    XCTAssertEqual(comps.second, 44, "Second is incorrect")
  }

  func testJSONStringFromDate() {
    var dateComponents = DateComponents()
    dateComponents.year   = 2014
    dateComponents.month  = 4
    dateComponents.day    = 24
    dateComponents.hour   = 12
    dateComponents.minute = 35
    dateComponents.second = 44
    
    let asDate = calendar!.date(from: dateComponents)
    XCTAssertNotNil(asDate, "dateFromComponents is nil")
    
    let asString = asDate!.pqg_jsonString() as String
    XCTAssertEqual(asString, "2014-04-24T12:35:44Z", "String not generated correctly")
  }

}
