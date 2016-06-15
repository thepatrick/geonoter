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
  
  required init(store: PQGPersistStore) {
    self.store = store
    self.primaryKey = PQGModel.primaryKeyForNewInstance()
    self.isNew = true
    self.isHydrated = true
  }
  
  required init(primaryKey: Int64, store: PQGPersistStore) {
    self.store = store
    self.primaryKey = primaryKey
  }
  
  //MARK: - Lifecycle
  
  func hydrate() -> Self {
    if !isHydrated {
      store.withDatabase { db in
        if let result = db.executeQuery("SELECT * FROM \(self.tableName()) WHERE id = ?", NSNumber(value: self.primaryKey)) {
            let next = result.next()
            assert(next == true, "Attempt to hydate a model that does not exist in the database")
            self.hydrateRequired(result)
            result.close()            
        }
      }
      isHydrated = true
    }
    return self
  }
  
  func hydrateRequired(_ row: FMResultSet) {
    NSLog("hydrateRequired not implemeneted in \(self)")
    fatalError("hydrateRequired not implemented in PQGModel subclass")
  }
  
  func dehydrateIfPossible() {
    if !isDirty {
      dehydrate()
      isHydrated = false
    }
  }
  
  func dehydrate() {
    NSLog("dehydrate not implemeneted in \(self)")
    fatalError("dehydrate not implemented in PQGModel subclass")
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
  
  func saveForNew(_ db: FMDatabase) {
    NSLog("saveForNew not implemeneted in \(self)")
    fatalError("saveForNew not implemented in PQGModel subclass")
  }
  
  func saveForUpdate(_ db: FMDatabase) {
    NSLog("saveForUpdate not implemeneted in \(self)")
    fatalError("saveForUpdate not implemented in PQGModel subclass")
  }
  
  class func tableName() -> String {
    NSLog("saveForUpdate not implemeneted in \(self)")
    fatalError("tableName not implemented in PQGModel subclass")
  }
  
  func tableName() -> String {
    return self.dynamicType.tableName()
  }
  
  func destroy() {
    willDestroy()
    store.withDatabase { db in
      db.executeUpdate("DELETE FROM \(self.tableName()) WHERE id = ?", NSNumber(value: self.primaryKey))
      return
    }
    wasDestroyed()
  }
  
  func willDestroy() {
    
  }
  
  func wasDestroyed() {
    
  }
  
  //MARK: - Helpers
  
  func numberWithInt64(_ number: Int64?) -> NSNumber? {
    if let realValue = number {
      return NSNumber(value: realValue)
    }
    return nil
  }
  
  func numberWithDouble(_ number: Double?) -> NSNumber? {
    if let realValue = number {
      return NSNumber(value: realValue)
    }
    return nil
  }
  
}
