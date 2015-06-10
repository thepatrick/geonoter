//
//  PQGModelCache.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 2/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

protocol PQGModelCacheable {

  init(primaryKey: Int64, store: PQGPersistStore)
  
  func save()
  
  func dehydrate()
  
  static func tableName() -> String
  
}

class PQGModelCache<T: PQGModelCacheable> {
  
  unowned let store : PQGPersistStore
  private var defaultSort : String
  
  private var cache = [NSNumber: T]()
  
  init(store: PQGPersistStore, defaultSort: String) {
    self.store = store
    self.defaultSort = defaultSort
  }
  
  func cacheKey(primaryKey: Int64) -> NSNumber {
    return NSNumber(longLong: primaryKey)
  }
  
  func get(primaryKey: Int64) -> T {
    if let thing = cache[cacheKey(primaryKey)] {
      return thing
    }
    let newItem = T(primaryKey: primaryKey, store: store)
    cache[cacheKey(primaryKey)] = newItem
    return newItem
  }
  
  func removeCachedObject(primaryKey: Int64) {
    cache.removeValueForKey(cacheKey(primaryKey))
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
  
  var tableName : String {
    return T.tableName()
  }
  
}


class PQGModelQueryBuilder<T: PQGModelCacheable> {
  
  let cache: PQGModelCache<T>
  let store: PQGPersistStore

  var conditions: String?
  var sort: String
  
  init(cache: PQGModelCache<T>) {
    self.cache = cache
    self.store = cache.store
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
      let whereClause = self.conditions != nil ? "WHERE \(self.conditions!)" : ""
      let query = "SELECT id FROM \(self.cache.tableName) \(whereClause) ORDER BY \(self.sort)"
      let res = db.executeQuery(query)
      while res.next() {
        items.append(self.cache.get(res.longLongIntForColumn("id")))
      }
    }
    return items
  }
  
}