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
  
  private var cache = [Int64: T]()
  
  init(store: PQGPersistStore) {
    self.store = store
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
  
}
