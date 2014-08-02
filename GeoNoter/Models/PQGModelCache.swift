//
//  PQGModelCache.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 2/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

class PQGModelCache<T: PQGModel> {
  
  unowned let store : PQGPersistStore
  private var defaultSort : String
  
  private var cache = [Int64: T]()
  
  init(store: PQGPersistStore, defaultSort: String) {
    self.store = store
    self.defaultSort = defaultSort
  }
  
  func get(primaryKey: Int64) -> T {
    if let thing = cache[primaryKey] {
      return thing
    }
    let newItem = T(primaryKey: primaryKey, store: store)
    cache[primaryKey] = newItem
    return newItem
  }
  
  func removeCachedObject(primaryKey: Int64) {
    cache.removeValueForKey(primaryKey)
  }
  
  func save() {
    for item in cache.values {
      item.save()
    }
  }
  
  func dehydrate() {
    for item in cache.values {
      item.dehydrate()
    }
  }
  
  var find : PQGModelQueryBuilder<T> {
    return PQGModelQueryBuilder<T>(cache: self)
  }
  
  
  var all : [T] {
    return find.all
  }
  
}


class PQGModelQueryBuilder<T: PQGModel> {
  
  unowned let cache: PQGModelCache<T>

  private var conditions: String?
  private var sort: String
  
  init(cache: PQGModelCache<T>) {
    self.cache = cache
    self.sort = cache.defaultSort
  }
  
  
  func with(query: String) -> Self {
    self.conditions = query
    return self
  }
  
  
  func orderBy(sort: String) -> Self {
    self.sort = sort
    return self
  }
  
  var all: [T] {
  var items = [T]()
    cache.store.withDatabase { db in
      let whereClause = self.conditions ? "WHERE \(self.conditions)" : ""
      let res = db.performQuery("SELECT id FROM tag \(whereClause) ORDER BY \(self.sort)")
      
      let enumerator = res.rowEnumerator()
      while let row = enumerator.nextObject() as? SQLRow {
        items.append(self.cache.get(row.longLongForColumn("id")))
      }
    }
    return items
  }
  
}