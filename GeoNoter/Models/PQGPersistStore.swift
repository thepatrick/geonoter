//
//  PQGPersistStore.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 1/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

@objc class PQGPersistStore: NSObject {
  
  lazy var tags : PQGModelCache<PQGTag> = PQGModelCache<PQGTag>(store: self, defaultSort: "name ASC")
  lazy var attachments : PQGModelCache<PQGAttachment> = PQGModelCache<PQGAttachment>(store: self, defaultSort: "recorded_at DESC")
  lazy var points : PQGModelCache<PQGPoint> = PQGModelCache<PQGPoint>(store: self, defaultSort: "name ASC")
  
  private var db : SQLDatabase?
  private let dbLock   = dispatch_queue_create("PQGPersistStore", DISPATCH_QUEUE_SERIAL)
  
  //MARK: - Helpers
  
  class func fileExists(path: NSURL) -> (Bool, Bool) {
    var error: NSError?
    var isDirectory: ObjCBool = ObjCBool(0)
    if NSFileManager.defaultManager().fileExistsAtPath(path.path, isDirectory: &isDirectory) {
      return (true, isDirectory.getLogicValue())
    } else {
      return (false, false)
    }
    
  }

  class func URLForDocument(path: String) -> NSURL {
    var err : NSError?
    let pathURL = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: &err)
    assert(pathURL != nil, "Failed to get Documents directory")
    return pathURL.URLByAppendingPathComponent(path)
  }
  
  class func attachmentsDirectory() -> NSURL {
    let dir = URLForDocument("Attachments")
    let (exists, isDirectory) = fileExists(dir)
    if !exists {
      let success = NSFileManager.defaultManager().createDirectoryAtPath(dir.path, withIntermediateDirectories: true, attributes: nil, error: nil)
      assert(success, "Failed to create attachments directory")
    }
    return dir
  }
  
  private class func URLForCacheResource(path: String) -> NSURL {
    var err : NSError?
    let pathURL = NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: &err)
    assert(pathURL != nil, "Failed to get caches directory")
    return pathURL.URLByAppendingPathComponent(path)
  }
  
  class func attachmentsCacheDirectory() -> NSURL {
    let dir = URLForCacheResource("Attachments")
    let (exists, isDirectory) = fileExists(dir)
    if !exists {
      let success = NSFileManager.defaultManager().createDirectoryAtPath(dir.path, withIntermediateDirectories: true, attributes: nil, error: nil)
      assert(success, "Failed to create attachments cache directory")
    }
    return dir
  }
  
  //MARK: - Lifecycle
  
  init() {
  }
  
  convenience init(file: NSURL) {
    self.init()
    // openDatabase(file)
  }
  
  deinit {
    if db {
      // closeDatabase()
    }
  }
  
  func openDatabase(fileName: NSURL) -> Bool {
    let (exists, isDirectory) = self.dynamicType.fileExists(fileName)
    
    let db = SQLDatabase(file: fileName.path)
    db.open()
    
    self.db = db
    
    if !exists {
      NSLog("First run, create basic file format")
      withDatabase { db in
        db.performQuery("CREATE TABLE sync_status_and_version (last_sync datetime, version integer)")
        db.performQuery("INSERT INTO sync_status_and_version VALUES (NULL, 0)")
      }
    }
    
    var version = 0
    
    withDatabase { db in
      let res = db.performQuery("SELECT last_sync, version FROM sync_status_and_version;")
      let row = res.rowAtIndex(0)
      version = row.integerForColumn("version")
    }
    
    NSLog("The version: \(version)")
    
    // migrateFrom(version)
    
    return true
  }
  
  func closeDatabase() {
    if db {
      withDatabase { db in
        db.performQuery("COMMIT")
        db.close()
      }
      db = nil
    }
  }
  
  func withDatabase(block: (SQLDatabase)->()) {
    assert(db, "withDatabase called with no database available")
    dispatch_sync(dbLock) { [unowned self] in
      block(self.db!)
    }
  }
  
  //MARK: - Migrations
  
  func migrateFrom(version: Int) {
    
    withDatabase { db in

      if version < 1 {
        NSLog("Database migrating to v1...")
  
        db.performQueries([
          "CREATE TABLE trip (id INTEGER PRIMARY KEY, name TEXT, start DATETIME, end DATETIME)",
          "UPDATE sync_status_and_version SET version = 1"
        ])
        NSLog("Database migrated to v1.")
      }
      
      if version < 2 {
        NSLog("Database migrating to v2...")
        db.performQueries([
          "INSERT INTO trip (name, start, end) VALUES ('Test Trip', '2008-01-01', '2008-12-31')",
          "UPDATE sync_status_and_version SET version = 2"
        ])
        NSLog("Database migrated to v2.")
      }
      
      if version < 3 {
        NSLog("Database migrating to v3...")
        db.performQueries([
          "CREATE TABLE tag (id INTEGER PRIMARY KEY, name TEXT)",
          "CREATE TABLE trip_tag (trip_id INTEGER, tag_id INTEGER)",
          "CREATE TABLE point (id INTEGER PRIMARY KEY, trip_id INTEGER, friendly_name TEXT, name TEXT, memo TEXT, recorded_at DATETIME, latitude NUMBER, longitude NUMBER)",
          "CREATE TABLE point_tag (point_id INTEGER, tag_id INTEGER)",
          "UPDATE sync_status_and_version SET version = 3"
        ])
        NSLog("Database migrated to v3.")
      }
      
      if version < 4 {
        NSLog("Database migrating to v4...")
        db.performQueries([
          "INSERT INTO tag (name) VALUES ('Test Tag')",
          "INSERT INTO tag (name) VALUES ('Personal')",
          "UPDATE sync_status_and_version SET version = 4"
        ])
        NSLog("Database migrated to v4.")
      }
      
      if version < 5 {
        NSLog("Database migrating to v5...")
        db.performQueries([
          "INSERT INTO point (trip_id, friendly_name, name, memo, recorded_at, latitude, longitude) VALUES (1, 'Vancouver BC, Canada', 'Home', 'No memo', '2009-01-12 21:18:00', 49.283588, -123.126373)",
          "INSERT INTO point_tag (point_id, tag_id) VALUES (1, 1)",
          "INSERT INTO point_tag (point_id, tag_id) VALUES (1, 2)",
          "UPDATE sync_status_and_version SET version = 5"
        ])
        NSLog("Database migrated to v5.")
      }
  
      if version < 6 {
        NSLog("Database migrating to v6...")
        db.performQueries([
          "CREATE TABLE attachment (id INTEGER PRIMARY KEY, point_id INTEGER, friendly_name TEXT, kind TEXT, memo TEXT, file_name TEXT, recorded_at DATETIME)",
          "UPDATE sync_status_and_version SET version = 6"
        ])
        NSLog("Database migrated to v6.");
      }
    }
  }
  
  //MARK: - Cache control
  
  func tellCacheToSave() {
    attachments.save()
    points.save()
    tags.save()
  }
  
  func tellCacheToDehydrate() {
    attachments.dehydrate()
    points.dehydrate()
    tags.dehydrate()
  }
  
}
