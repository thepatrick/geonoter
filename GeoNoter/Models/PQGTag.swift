//
//  PQGTag.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 31/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

class PQGTag: PQGModel {
  
  override var tableName : String { return "tag" }
  
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
  
  override func hydrateRequired(row: SQLRow) {
    _name = row.stringForColumn("name")
  }
  
  override func saveForNew(db: SQLDatabase) {
    let sql = "INSERT INTO \(tableName) (id, name) VALUES (\(primaryKey), '\(SQLDatabase.prepareStringForQuery(_name))')"
    db.performQuery(sql)
  }
  
  override func saveForUpdate(db: SQLDatabase) {
    let sql = "UPDATE \(tableName) SET name = '\(SQLDatabase.prepareStringForQuery(_name))' WHERE id = \(primaryKey)"
    db.performQuery(sql)
  }
  
  var points : [PQGPoint] {
    return store.points.find.with("id in (SELECT point_id FROM point_tag WHERE tag_id = \(primaryKey))").all
  }
  
  override func willDestroy() {
    store.withDatabase { db in
      db.performQuery("DELETE FROM point_tag WHERE tag_id = \(self.primaryKey)")
      return
    }
  }
  
  override func wasDestroyed() {
    store.tags.removeCachedObject(primaryKey)
  }
  
}