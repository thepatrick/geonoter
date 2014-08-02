//
//  PQGAttachment.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 1/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

class PQGAttachment: PQGModel {
  
  override var tableName : String { return "attachment" }
  
  //MARK: - Private Variables
  
  private var _pointId:      Int64?
  private var _friendlyName: String?
  private var _kind:         String?
  private var _memo:         String?
  private var _fileName:     String?
  private var _recordedAt:   NSDate?
  
  //MARK: - Public properties
  
  var pointId : Int64? {
  get {
    return hydrate()._pointId
  }
  set (newPointId) {
    hydrate()._pointId = newPointId
  }
  }
  
  var friendlyName : String? {
  get {
    return hydrate()._friendlyName
  }
  set (newFriendlyName) {
    hydrate()._friendlyName = newFriendlyName
  }
  }
  
  var kind : String? {
  get {
    return hydrate()._kind
  }
  set (newKind) {
    hydrate()._kind = newKind
  }
  }
  
  var memo : String? {
  get {
    return hydrate()._memo
  }
  set (newMemo) {
    hydrate()._memo = newMemo
  }
  }
  
  var fileName : String? {
  get {
    return hydrate()._fileName
  }
  set (fileName) {
    hydrate()._fileName = fileName
  }
  }  
  
  var recordedAt : NSDate? {
  get {
    return hydrate()._recordedAt
  }
  set (recordedAt) {
    hydrate()._recordedAt = recordedAt
  }
  }
  
  var point: PQGPoint {
  get {
    return store.points.get(pointId!)
  }
  set (point) {
    hydrate()._pointId = point.primaryKey
  }
  }
  
  var filesystemURL : NSURL? {
  if let fileName = self.fileName {
    return PQGPersistStore.attachmentsDirectory().URLByAppendingPathComponent(fileName)
    }
    return nil
  }
  
  var data : NSData? {
  if let fsURL = filesystemURL {
    return NSData(contentsOfURL: fsURL)
    }
    return nil
  }
  
  //MARK: - Lifecycle
  
  override func dehydrate() {
    _pointId = nil
    _friendlyName = nil
    _kind = nil
    _memo = nil
    _fileName = nil
    _recordedAt = nil
  }
  
  override func hydrateRequired(row: SQLRow) {
    _pointId      = row.longLongForColumn("point_id")
    _friendlyName = row.stringForColumn("friendly_name")
    _kind         = row.stringForColumn("kind")
    _memo         = row.stringForColumn("memo")
    _fileName     = row.stringForColumn("file_name")
    _recordedAt   = row.dateForColumn("recorded_at")
  }
  
  override func saveForNew(db: SQLDatabase) {
    let sql = "INSERT INTO \(tableName) (id, point_id, friendly_name, kind, memo, file_name, recorded_at) " +
      "VALUES (\(primaryKey), \(_pointId), \(str(_friendlyName)), \(str(_kind)), \(str(_memo)), \(str(_fileName)), \(str(_recordedAt?.pqg_sqlDateString())))"
    db.performQuery(sql)
  }
  
  override func saveForUpdate(db: SQLDatabase)  {
    let sql = "UPDATE \(tableName) SET point_id = \(_pointId), friendly_name = \(str(_friendlyName)), kind = \(str(_kind)), " +
      "memo = \(str(_memo)), file_name = \(str(_fileName)), recorded_at =  \(str(_recordedAt?.pqg_sqlDateString()))" +
      "WHERE id = \(primaryKey)"
    db.performQuery(sql)
  }
  
  override func wasDestroyed() {
    store.attachments.removeCachedObject(primaryKey)
    if let fsURL = filesystemURL {
      NSFileManager.defaultManager().removeItemAtURL(fsURL, error: nil)
      NSFileManager.defaultManager().removeItemAtURL(fsURL.URLByAppendingPathExtension("cached.jpg"), error: nil)
      //TODO: Remove all cached image for size variants
    }
  }
  
  
//  convenience init(name: String, store: PersistStore) {
//    self.init(store: store)
//    self.name = name
//  }
  
  //MARK: - Attachment helpers
  
  func loadCachedImageForSize(largestSide: Int) -> UIImage? {
    let cachedPath = PQGPersistStore.attachmentsCacheDirectory().URLByAppendingPathComponent("\(largestSide)-\(fileName))")
    if NSFileManager.defaultManager().fileExistsAtPath(cachedPath.path) {
      let cachedImage = UIImage(contentsOfFileURL: cachedPath)
      NSLog("Loaded \(fileName) from \(cachedPath)")
      return cachedImage
    }
    let original = UIImage(contentsOfFileURL: filesystemURL)
    NSLog("img: \(original.size.width) x \(original.size.height)")
    let newCachedImage = original.pqg_scaleAndRotateImage(largestSide)
    NSLog("img: \(newCachedImage.size.width) x \(newCachedImage.size.height)")
    let data = UIImageJPEGRepresentation(newCachedImage, 1.0)
    data.writeToURL(cachedPath, atomically: true)
    NSLog("Wrote \(fileName) to \(cachedPath)")
    return newCachedImage
  }
}
