//
//  PQGModelCacheTests.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 10/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit
import XCTest

private var TestCacheableCount = 0

class PQGModelCacheTests: XCTestCase {
  
  class TestStore: PQGPersistStore {
    
    class TestSQLDatabase: FMDatabase {
    }
    
    override func withDatabase(_ block: (FMDatabase!) -> ()) {
      //let g = TestSQLDatabase()
    }
    
    
  }

  var sampleStore = TestStore()
  
  final class TestCachable: PQGModelCacheable {
    
    let primaryKey: Int64
    let store: PQGPersistStore
    
    init(primaryKey: Int64, store: PQGPersistStore) {
      TestCacheableCount += 1
      self.primaryKey = primaryKey
      self.store = store
    }
    
    var saveCount = 0
    var dehydrateCount = 0
    
    func save() {
      saveCount += 1
    }
    
    func dehydrate() {
      dehydrateCount += 1
    }
    
    class func tableName() -> String {
      return "TestCachableTableName"
    }
    
  }
  
  var testCache: PQGModelCache<TestCachable>!
  
  override func setUp() {
    TestCacheableCount = 0
    testCache = PQGModelCache<TestCachable>(store: sampleStore, defaultSort: "bananas ASC");
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
    testCache = nil
  }
  
  func testGet() {
    
    let testItem1 = testCache.get(1)
    XCTAssertNotNil(testItem1, "PQGModelCache returned an unexpected nil")
    XCTAssertEqual(TestCacheableCount, 1, "Did not create a fresh TestCachable")
    
    let testItem2 = testCache.get(2)
    XCTAssertNotNil(testItem2, "PQGModelCache returned an unexpected nil")
    XCTAssertEqual(TestCacheableCount, 2, "Did not create a fresh TestCachable")
    XCTAssertFalse(testItem1 === testItem2, "Requesting a different item returned the same object")
    
    let testItem3 = testCache.get(1)
    XCTAssertNotNil(testItem3, "PQGModelCache returned an unexpected nil")
    XCTAssertEqual(TestCacheableCount, 2, "Did not create a fresh TestCachable")
    XCTAssertTrue(testItem1 === testItem3, "Requesting the same item returned a different object")
    
  }
  
  func testRemoveCachedObject() {
    
    let testItem1 = testCache.get(1)
    XCTAssertEqual(TestCacheableCount, 1, "Did not create a fresh TestCachable")
    
    testCache.removeCachedObject(1)
    
    let testItem3 = testCache.get(1)
    XCTAssertEqual(TestCacheableCount, 2, "Did not create a fresh TestCachable")
    XCTAssertFalse(testItem1 === testItem3, "Requesting the same item returned a different object")
    
  }
  
  func testSave() {
    
    let testItems = (1...5).map { self.testCache.get($0) }
    
    for item in testItems {
      XCTAssertEqual(item.saveCount, 0, "save() not called")
    }
    
    for index in 1...5 {
      testCache.save()
      for item in testItems {
        XCTAssertEqual(item.saveCount, index, "save() not called")
      }
    }
    
  }
  
  func testDehydrate() {
    
    let testItems = (1...5).map { self.testCache.get($0) }
    
    for item in testItems {
      XCTAssertEqual(item.dehydrateCount, 0, "save() not called")
    }
    
    for index in 1...5 {
      testCache.dehydrate()
      for item in testItems {
        XCTAssertEqual(item.dehydrateCount, index, "save() not called")
      }
    }
  }
  
  func testFind() {
    let finder = testCache.find
    XCTAssertTrue(finder.store === sampleStore, "PQGModelQueryBuilder not given correct store")
    XCTAssertTrue(finder.cache === testCache, "PQGModelQueryBuilder not given correct cache")
//    XCTAssertEqual(finder.sort, "bananas ASC", "PQGModelQueryBuilder not given correct default sort")
  }
  
  func testAll() {
    //  var all : [T] {
    //    return find.all
    //  }
    //
  }
  
  func testTableName() {
    XCTAssertEqual(testCache.tableName, "TestCachableTableName", "tableName returned an unexpected result")
  }

}
