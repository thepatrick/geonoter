//
//  PQGPersistStore.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 1/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

public extension FMDatabase {
  
//  func executeUpdate(sql:String) -> Bool {
//    return executeUpdate(sql, withArgumentsInArray: [])
//  }
  
  func executeUpdate(sql:String, _ arguments: AnyObject?...) -> Bool {
    var args = [AnyObject]()
    for arg in arguments {
      if arg != nil {
        args.append(arg!)
      } else {
        args.append(NSNull())
      }
    }
    return executeUpdate(sql, withArgumentsInArray:args)
  }
  
  func executeQuery(sql:String, _ arguments: AnyObject?...) -> FMResultSet! {
    var args = [AnyObject]()
    for arg in arguments {
      if (arg != nil) {
        args.append(arg!)
      } else {
        args.append(NSNull())
      }
    }
    return executeQuery(sql, withArgumentsInArray:args)
  }
}

@objc public class PQGPersistStore: NSObject {
  
  var tags : PQGModelCache<PQGTag>!
  var attachments : PQGModelCache<PQGAttachment>!
  var points : PQGModelCache<PQGPoint>!
  
  private var queue : FMDatabaseQueue?
  
  //MARK: - Helpers
  
  class func fileExists(path: NSURL) -> (Bool, Bool) {
    var error: NSError?
    var isDirectory: ObjCBool = ObjCBool(0)
    if NSFileManager.defaultManager().fileExistsAtPath(path.path, isDirectory: &isDirectory) {
      return (true, isDirectory.boolValue)
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
  
  override init() {
    super.init()
    tags = PQGModelCache<PQGTag>(store: self, defaultSort: "name ASC")
    attachments = PQGModelCache<PQGAttachment>(store: self, defaultSort: "recorded_at DESC")
    points = PQGModelCache<PQGPoint>(store: self, defaultSort: "name ASC")
  }
  
  convenience init(file: NSURL) {
    self.init()
    openDatabase(file)
  }
  
  func openDatabase(fileName: NSURL) -> Bool {
    let (exists, isDirectory) = self.dynamicType.fileExists(fileName)
    
    self.queue = FMDatabaseQueue(path: fileName.path)
    
    withDatabase { db in
      db.setDateFormat(FMDatabase.storeableDateFormat("yyyy-MM-dd HH:mm:ss"))
    }
    
    if !exists {
      NSLog("First run, create basic file format")
      withDatabase { db in
        db.executeUpdate("CREATE TABLE sync_status_and_version (last_sync datetime, version integer)")
        db.executeUpdate("INSERT INTO sync_status_and_version VALUES (null, ?)", 1)
      }
    }
    
    var version = 0
    
    withDatabase { db in
      let res = db.executeQuery("SELECT version FROM sync_status_and_version;")
      if res.next() {
        version = res.longForColumn("version")
      }
      res.close()
    }
    
    NSLog("The version: \(version)")
    
    migrateFrom(version)
    
    return true
  }
  
  func closeDatabase() {
    queue = nil
  }
  
  func withDatabase(block: (FMDatabase!)->()) {
    assert(queue != nil, "withDatabase called with no database available")
    queue?.inDatabase(block)
  }
  
  //MARK: - Migrations
  
  func migrateFrom(version: Int) {
    
    withDatabase { db in

      if version < 1 {
        db.executeStatements(
          "CREATE TABLE trip (id INTEGER PRIMARY KEY, name TEXT, start DATETIME, end DATETIME); " +
          "UPDATE sync_status_and_version SET version = 1;"
        );
        
        NSLog("Database migrated to v1.")
      }
      
      if version < 2 {
        db.executeStatements(
          "INSERT INTO trip (name, start, end) VALUES ('Test Trip', '2008-01-01', '2008-12-31');" +
          "UPDATE sync_status_and_version SET version = 2;"
        )
        NSLog("Database migrated to v2.")
      }
      
      if version < 3 {
        db.executeStatements(
          "CREATE TABLE tag (id INTEGER PRIMARY KEY, name TEXT);" +
          "CREATE TABLE trip_tag (trip_id INTEGER, tag_id INTEGER);" +
          "CREATE TABLE point (id INTEGER PRIMARY KEY, trip_id INTEGER, friendly_name TEXT, name TEXT, memo TEXT, recorded_at DATETIME, latitude NUMBER, longitude NUMBER);" +
          "CREATE TABLE point_tag (point_id INTEGER, tag_id INTEGER);" +
          "UPDATE sync_status_and_version SET version = 3;"
        )
        NSLog("Database migrated to v3.")
      }
      
      if version < 4 {
        db.executeStatements(
          "INSERT INTO tag (name) VALUES ('Test Tag'); " +
          "INSERT INTO tag (name) VALUES ('Personal'); " +
          "UPDATE sync_status_and_version SET version = 4;"
        )
        NSLog("Database migrated to v4.")
      }
      
      if version < 5 {
        db.executeStatements(
          "INSERT INTO point (trip_id, friendly_name, name, memo, recorded_at, latitude, longitude) VALUES (1, 'Vancouver BC, Canada', 'Home', 'No memo', '2009-01-12 21:18:00', 49.283588, -123.126373); " +
          "INSERT INTO point_tag (point_id, tag_id) VALUES (1, 1); " +
          "INSERT INTO point_tag (point_id, tag_id) VALUES (1, 2); " +
          "UPDATE sync_status_and_version SET version = 5;"
        )
        NSLog("Database migrated to v5.")
      }
  
      if version < 6 {
        db.executeStatements(
          "CREATE TABLE attachment (id INTEGER PRIMARY KEY, point_id INTEGER, friendly_name TEXT, kind TEXT, memo TEXT, file_name TEXT, recorded_at DATETIME); " +
          "UPDATE sync_status_and_version SET version = 6;"
        )
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
