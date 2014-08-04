//
//  PQGModel.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 31/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

class PQGModel: NSObject, PQGModelCacheable {

  let primaryKey: Int64

  let store: PQGPersistStore
  
  var isDirty = false
  var isHydrated : Bool = false
  var isNew = false
  
  class func primaryKeyForNewInstance() -> Int64 {
    let urandom = (UInt64(arc4random()) << 32 | UInt64(arc4random()))
    
    return Int64(urandom & 0x7FFFFFFFFFFFFFFF)
  }

  //MARK: - Initializers
  
  init(store: PQGPersistStore) {
    self.store = store
    self.primaryKey = PQGModel.primaryKeyForNewInstance()
    self.isNew = true
    self.isHydrated = true
  }
  
  init(primaryKey: Int64, store: PQGPersistStore) {
    self.store = store
    self.primaryKey = primaryKey
  }
  
  //MARK: - Lifecycle
  
  func hydrate() -> Self {
    if !isHydrated {
      store.withDatabase { db in
        let result = db.executeQuery("SELECT * FROM \(self.tableName()) WHERE id = ?", self.int64OrNil(self.primaryKey))
        let next = result.next()
        assert(next == true, "Attempt to hydate a model that does not exist in the database")
        self.hydrateRequired(result)
        result.close()
      }
      isHydrated = true
    }
    return self
  }
  
  func hydrateRequired(row: FMResultSet) {
    NSLog("hydrateRequired not implemeneted in \(NSStringFromClass(self.dynamicType))")
    assert(false, "hydrateRequired not implemented in PQGModel subclass")
  }
  
  func dehydrateIfPossible() {
    if !isDirty {
      dehydrate()
      isHydrated = false
    }
  }
  
  func dehydrate() {
    NSLog("dehydrate not implemeneted in \(NSStringFromClass(self.dynamicType))")
    assert(false, "dehydrate not implemented in PQGModel subclass")
  }
  
  func save() {
    store.withDatabase { db in
      if self.isNew {
        self.saveForNew(db)
      } else {
        self.saveForUpdate(db)
      }
    }
  }
  
  func saveForNew(db: FMDatabase) {
    NSLog("saveForNew not implemeneted in \(NSStringFromClass(self.dynamicType))")
    assert(false, "saveForNew not implemented in PQGModel subclass")
  }
  
  func saveForUpdate(db: FMDatabase) {
    NSLog("saveForUpdate not implemeneted in \(NSStringFromClass(self.dynamicType))")
    assert(false, "saveForUpdate not implemented in PQGModel subclass")
  }
  
  class func tableName() -> String {
    NSLog("saveForUpdate not implemeneted in \(NSStringFromClass(self.dynamicType))")
    assert(false, "tableName not implemented in PQGModel subclass")
    return ""
  }
  
  func tableName() -> String {
    return self.dynamicType.tableName()
  }
  
  func destroy() {
    willDestroy()
    store.withDatabase { db in
      db.executeUpdate("DELETE FROM \(self.tableName()) WHERE id = ?", self.int64OrNil(self.primaryKey))
      return
    }
    wasDestroyed()
  }
  
  func willDestroy() {
    
  }
  
  func wasDestroyed() {
    
  }
  
  //MARK: - Helpers
  
  func orNil(value: AnyObject?) -> AnyObject {
    if let realValue: AnyObject = value {
      return "\(value)"
    } else {
      return NSNull()
    }
  }
  
  func int64OrNil(value: Int64?) -> AnyObject {
    if let realValue = value {
      return NSNumber.numberWithLongLong(realValue)
    } else {
      return NSNull()
    }
  }
  
}
