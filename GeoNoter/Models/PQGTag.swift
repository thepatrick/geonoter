//
//  PQGTag.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 31/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

extension PQGPersistStore {
  
  func getTagsWithConditions(conditions: String?, sort: String?) -> [PQGTag] {
    var tags = [PQGTag]()
    withDatabase { db in
      let whereClause = conditions ? "WHERE \(conditions)" : ""
      let orderBy = sort ? sort! : "name ASC"
      let res = db.performQuery("SELECT id FROM tag \(whereClause) ORDER BY \(orderBy)")
      
      let enumerator = res.rowEnumerator()
      while let row = enumerator.nextObject() as? SQLRow {
        tags.append(self.tags.get(row.longLongForColumn("id")))
      }
    }
    return tags
  }
  
  func getAllTags() -> [PQGTag] {
    return getTagsWithConditions(nil, sort: nil)
  }
  
}

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
    let cond = "id in (SELECT point_id FROM point_tag WHERE tag_id = \(primaryKey))"
    return store.getPointsWithConditions(cond, sort: nil)
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