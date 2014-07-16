//
//  PQGStringUUIDTests.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 15/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit
import XCTest

class PQGStringUUIDTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStringWithUUID() {
        // This is an example of a functional test case.
      
      XCTAssertNotNil(NSString.stringWithUUID(), "stringWithUUID returned nil!")
      
      let test1 = NSString.stringWithUUID() as String
      let onlyCharacters = test1.stringByReplacingOccurrencesOfString("-", withString: "", options: .CaseInsensitiveSearch, range: nil)
      
      XCTAssertEqual(countElements(onlyCharacters), 32, "stringWithUUID returned an unxpected string \(test1) vs \(onlyCharacters)")
      XCTAssertEqual(countElements(test1), 36, "stringWithUUID returned a string of unexpected length")
      
      let test2 = NSString.stringWithUUID() as String
      
      XCTAssertNotEqual(test1, test2, "Successive stringWithUUID calls must return unique values")
    }

    func testPerformanceExample() {
        self.measureBlock() {
          NSString.stringWithUUID()
          return
        }
    }

}
