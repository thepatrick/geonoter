//
//  PQGPersistStoreTrips.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit
import XCTest

class PQGPersistStoreTags: XCTestCase {
  
  var store : PersistStore!

  override func setUp() {
    super.setUp()
    
    let testFile = PersistStore.pathForResource("test.db")
    
    let fm = NSFileManager.defaultManager()
    if fm.fileExistsAtPath(testFile) {
      var error : NSError?;
      if !fm.removeItemAtPath(testFile, error: &error) {
        XCTAssert(false, "Unable to remove test.db \(error!.localizedDescription)");
      }
    }
    store = PersistStore(file: testFile);
  }
  
  override func tearDown() {
    if store {
      store.closeDatabase()
    }
    
    super.tearDown()
  }
  
  func testInsertTag() {
    let tag = Tag()
    
    tag.name = "My tag"
    XCTAssertTrue(store.insertOrUpdateTag(tag), "Inserting a tag should return true")
    XCTAssertNotNil(tag.dbId, "Inserted tag should have a database ID")
    
    store.removeTagFromCache(tag.dbId.integerValue)
    let newTag = store.getTag(tag.dbId.integerValue)
    XCTAssertNotNil(newTag, "Fetching added tag failed")
    
    XCTAssertNotEqualObjects(tag, newTag, "Tag not removed from cache")
    XCTAssertEqual(newTag.dbId.integerValue, tag.dbId.integerValue, "Incorrect tag ID returned!")
    XCTAssertTrue(newTag.hydrate().name == tag.name, "Name was not saved correctly")
  }

  func testUpdateTag() {
    let tag = Tag()
    
    tag.name = "My tag"
    XCTAssertTrue(store.insertOrUpdateTag(tag), "Inserting a tag should return true")
    XCTAssertNotNil(tag.dbId, "Inserted tag should have a database ID")
    
    tag.name = "New tag name";
    XCTAssertFalse(store.insertOrUpdateTag(tag), "Updating a tag should return false")
    
    store.removeTagFromCache(tag.dbId.integerValue)
    let newTag = store.getTag(tag.dbId.integerValue)
    XCTAssertNotNil(newTag, "Fetching added tag failed")
    
    XCTAssertNotEqualObjects(tag, newTag, "Tag not removed from cache")
    XCTAssertEqual(newTag.dbId.integerValue, tag.dbId.integerValue, "Incorrect tag ID returned!")
    XCTAssertTrue(newTag.hydrate().name == tag.name, "Name was saved correctly")
    
  }
  
  func tagMaker(tagName: String) -> Tag {
    let tag = Tag()
    tag.name = tagName
    store.insertOrUpdateTag(tag)
    return tag
  }
  
  func testGetAllTags() {
    let tags = [
      tagMaker("tag1"),
      tagMaker("tag2"),
      tagMaker("tag3")
    ]
    
    let foundTags = store.getAllTags()
    XCTAssertEqual(foundTags.count, tags.count + 2, "Expected three tags, got \(foundTags.count)")
    
  }
  

  func testGetTagsWithConditions() {
  }
  
  
  func testGetTag() {
  }
  
}
