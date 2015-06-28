//: Playground - noun: a place where people can play

import UIKit

class PQGPersistStore {
  var hello = "World"
}

protocol PQGModel2 {
  var primaryKey: Int64 { get }
  var store: PQGPersistStore { get }
  
  var isDirty: Bool { get set }
  var isHydrated: Bool { get set }
  var isNew: Bool { get set }
}

extension PQGModel2 {
  
  static func primaryKeyForNewInstance() -> Int64 {
    let urandom = (UInt64(arc4random()) << 32 | UInt64(arc4random()))
    
    return Int64(urandom & 0x7FFFFFFFFFFFFFFF)
  }
  
}

struct PQGPoint2 : PQGModel2 {
  let primaryKey: Int64
  let store: PQGPersistStore

  var isDirty = false
  var isHydrated = false
  var isNew = false
  
  init (store:PQGPersistStore) {
    self.store = store
    self.primaryKey = PQGModel2.primaryKeyForNewInstance()
    self.isNew = true
    self.isHydrated = true
  }

}


let store = PQGPersistStore()

let x = PQGPoint2(primaryKey: PQGModel2.primaryKeyForNewInstance(), store: store)

//
//class func primaryKeyForNewInstance() -> Int64 {
//  let urandom = (UInt64(arc4random()) << 32 | UInt64(arc4random()))
//  
//  return Int64(urandom & 0x7FFFFFFFFFFFFFFF)
//}
//
////MARK: - Initializers
//
//required init(store: PQGPersistStore) {
//  self.store = store
//  self.primaryKey = PQGModel.primaryKeyForNewInstance()
//  self.isNew = true
//  self.isHydrated = true
//}
//
//required init(primaryKey: Int64, store: PQGPersistStore) {
//  self.store = store
//  self.primaryKey = primaryKey
//}
//
