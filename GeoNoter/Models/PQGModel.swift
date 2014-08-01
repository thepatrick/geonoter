//
//  PQGModel.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 31/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

class PQGModel: NSObject {

  let primaryKey: Int64

  let store: PQGPersistStore
  
  var isDirty = false
  var isHydrated : Bool = false
  var isNew = false
  
  var tableName: String {
    assert(false, "tableName not implemented in PQGModel subclass")
    return ""
  }
  
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
        let result = db.performQuery("SELECT * FROM TAG WHERE id = \( self.primaryKey )")
        assert(result.rowCount > 0, "Could not hydrate a tag that does not exist in the database");
        let row = result.rowAtIndex(0)
        self.hydrateRequired(row!)
      }
      isHydrated = true
    }
    return self
  }
  
  func hydrateRequired(row: SQLRow) {
    NSLog("hydrateRequired not implemeneted in \(tableName)")
    assert(false, "hydrateRequired not implemented in PQGModel subclass")
  }
  
  func dehydrateIfPossible() {
    if !isDirty {
      dehydrate()
      isHydrated = false
    }
  }
  
  func dehydrate() {
    NSLog("dehydrate not implemeneted in \(tableName)")
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
  
  func saveForNew(db: SQLDatabase) {
    NSLog("saveForNew not implemeneted in \(tableName)")
    assert(false, "saveForNew not implemented in PQGModel subclass")
  }
  
  func saveForUpdate(db: SQLDatabase) {
    NSLog("saveForUpdate not implemeneted in \(tableName)")
    assert(false, "saveForUpdate not implemented in PQGModel subclass")
  }
  
  func destroy() {
    willDestroy()
    store.withDatabase { db in
      let sql = "DELETE FROM \(self.tableName) WHERE id = \(self.primaryKey)"
      db.performQuery(sql)
    }
    wasDestroyed()
  }
  
  func willDestroy() {
    
  }
  
  func wasDestroyed() {
    
  }
  
  //MARK: - Helpers
  
  func orNil(value: AnyObject?) -> String {
    if let realValue: AnyObject = value {
      return "\(value)"
    } else {
      return "null"
    }
  }
  
  func str(value: String?) -> String {
    if let realValue = value {
      return "'\(SQLDatabase.prepareStringForQuery(value))'"
    } else {
      return "null"
    }
  }
  
}
