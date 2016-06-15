//
//  PQGTag.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 31/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

final class PQGTag: PQGModel {
  
  override class func tableName() -> String {
    return "tag"
  }
  
  private var _name : String?
  
  convenience init(name: String, store: PQGPersistStore) {
    self.init(store: store)
    self.name = name
  }
  
  var name : String? {
    get {
      return hydrate()._name!
    }
    set(newName) {
      hydrate()._name = newName
      isDirty = true
    }
  }
  
  override func dehydrate() {
    _name = nil
  }
  
  override func hydrateRequired(_ row: FMResultSet) {
    _name = row.string(forColumn: "name")
  }
  
  override func saveForNew(_ db: FMDatabase) {
    db.executeUpdate("INSERT INTO \(tableName()) (id, name) VALUES (?, ?)",
      NSNumber(value: self.primaryKey),
      name ?? NSNull()
    )
  }
  
  override func saveForUpdate(_ db: FMDatabase) {
    db.executeUpdate("UPDATE \(tableName()) SET name = ? WHERE id = ?",
      name ?? NSNull(),
      NSNumber(value: self.primaryKey)
    )
  }
  
  var points : [PQGPoint] {
    return store.points.find.with("id in (SELECT point_id FROM point_tag WHERE tag_id = \(primaryKey))").all
  }
  
  override func willDestroy() {
    store.withDatabase { db in
      db.executeUpdate("DELETE FROM point_tag WHERE tag_id = ?", NSNumber(value: self.primaryKey))
      return
    }
  }
  
  override func wasDestroyed() {
    store.tags.removeCachedObject(primaryKey)
  }
  
}
