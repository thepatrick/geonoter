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
    NSLog("setUp!")
    super.setUp()
    
    let testFile = PersistStore.pathForResource("test.db")
    
    let fm = NSFileManager.defaultManager()
    if fm.fileExistsAtPath(testFile) {
      NSLog("Should remove \(testFile)")
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
    NSLog("tearDown!")
  }
  
  func testInsertTag() {
    
    NSLog("testInsertTag")
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
    
    NSLog("<< testInsertTag")
  }

  func testUpdateTag() {
    
    NSLog("testUpdateTag")
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
    
    
    NSLog("<< testUpdateTag")
  }
  
  func tagMaker(tagName: String) -> Tag {
    
    NSLog("tagMaker")
    let tag = Tag()
    tag.name = tagName
    store.insertOrUpdateTag(tag)
    return tag
  }
  
  func testGetAllTags() {
    NSLog("testGetAllTags")
    
    let foundTags = store.getAllTags()
    XCTAssertEqual(foundTags.count, 2, "Expected three tags, got \(foundTags.count)")
    NSLog("<< testGetAllTags")
    
  }
  
  func xarby(tags: [Tag], idx : Int) {
    var sortedTag1 = tags[0].hydrate()
    var sortedTag2 = tags[1].hydrate()
    let sorted = sortedTag1.name < sortedTag2.name
    XCTAssertTrue(sortedTag1.name < sortedTag2.name, "\(sortedTag1.name) is not before \(sortedTag2.name)")
  }

  func testGetTagsWithConditions() {
    let tag1 = tagMaker("tag1")
    let tag2 = tagMaker("tag2")
    let tag3 = tagMaker("tag3")
    
    store.removeTagFromCache(tag1.dbId.integerValue)
    store.removeTagFromCache(tag2.dbId.integerValue)
    store.removeTagFromCache(tag3.dbId.integerValue)
    
    let allTags = store.getTagsWithConditions(nil, andSort: nil)
    XCTAssertEqual(allTags.count, 5, "Expected 5 tags, got \(allTags.count)")
    
    
    let likeTags = store.getTagsWithConditions("name LIKE 'tag%'", andSort: nil)
    XCTAssertEqual(likeTags.count, 3, "Expected 3 tags, got \(likeTags.count)")
    
    let noTags = store.getTagsWithConditions("name = 'no-matching-tags'", andSort: nil)
    XCTAssertEqual(noTags.count, 0, "Expected 3 tags, got \(noTags.count)")
    
    
    let sortedTags = store.getTagsWithConditions(nil, andSort: "name ASC") as [Tag]
    for i in 0..<(sortedTags.count - 1) {
      xarby(sortedTags, idx: i)
    }
    
    let sortedFilteredTags = store.getTagsWithConditions("name LIKE 'tag%'", andSort: "name ASC") as [Tag]
    XCTAssertEqual(sortedFilteredTags.count, 3, "Expected 3 tags, got \(sortedFilteredTags.count)")
    for i in 0..<(sortedFilteredTags.count - 1) {
      xarby(sortedFilteredTags, idx: i)
    }
  }
  
  
  func testGetTag() {
    let tag = store.getTag(1).hydrate()
    XCTAssertNotNil(tag, "Test tag not found")
    XCTAssertTrue(tag.name == "Test Tag", "Expected tag had name \(tag.name)")
    
    let tag2 = store.getTag(1)
    XCTAssertEqualObjects(tag, tag2, "getTag() did not return cached tag")

    store.removeTagFromCache(1)
    
    let tag3 = store.getTag(1)
    XCTAssertNotEqualObjects(tag, tag3, "getTag() returned a cached tag")
    
    tag3.destroy()
    
    let findTag = store.getTagsWithConditions("id = 1", andSort: nil)
    XCTAssertEqual(findTag.count, 0, "Tag was not destroyed")
  }
  
}
