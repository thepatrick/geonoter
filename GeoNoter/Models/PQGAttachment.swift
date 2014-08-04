//
//  PQGAttachment.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 1/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

class PQGAttachment: PQGModel, PQGModelCacheable {
  
  override class func tableName() -> String {
    return "attachment"
  }
    
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
  
  override func hydrateRequired(row: FMResultSet) {
    _pointId      = row.longLongIntForColumn("point_id")
    _friendlyName = row.stringForColumn("friendly_name")
    _kind         = row.stringForColumn("kind")
    _memo         = row.stringForColumn("memo")
    _fileName     = row.stringForColumn("file_name")
    _recordedAt   = row.dateForColumn("recorded_at")
  }
  
  override func saveForNew(db: FMDatabase) {
    db.executeUpdate("INSERT INTO \(tableName()) (id, point_id, friendly_name, kind, memo, file_name, recorded_at), " +
      "VALUES (?, ?, ?, ?, ?, ?, ?)",
      int64OrNil(self.primaryKey),
      int64OrNil(pointId),
      orNil(friendlyName),
      orNil(kind),
      orNil(memo),
      orNil(fileName),
      orNil(recordedAt)
    )
  }
  
  override func saveForUpdate(db: FMDatabase)  {
    db.executeUpdate("UPDATE \(tableName()) SET point_id = ?, friendly_name = ?, kind = ?, " +
      "memo = ?, file_name = ?, recorded_at = ? WHERE id = ?",
      int64OrNil(pointId),
      orNil(friendlyName),
      orNil(kind),
      orNil(memo),
      orNil(fileName),
      orNil(recordedAt),
      int64OrNil(primaryKey)
    )
  }
  
  override func wasDestroyed() {
    store.attachments.removeCachedObject(primaryKey)
    if let fsURL = filesystemURL {
      NSFileManager.defaultManager().removeItemAtURL(fsURL, error: nil)
      NSFileManager.defaultManager().removeItemAtURL(fsURL.URLByAppendingPathExtension("cached.jpg"), error: nil)
      //TODO: Remove all cached image for size variants
    }
  }
  
  //MARK: - Attachment helpers
  
  func createCacheDirIfMissing(cacheDirectory: NSURL) {
    let (exists, isDirectory) = PQGPersistStore.fileExists(cacheDirectory)
    
    if !exists {
      var err : NSError?
      let success = NSFileManager.defaultManager().createDirectoryAtPath(cacheDirectory.path, withIntermediateDirectories: true, attributes: nil, error: &err)
      if !success {
        NSLog("Error trying to create directory! \(err!.localizedDescription)")
      }
    }
  }
  
  func loadCachedImageForSize(largestSide: Int) -> UIImage? {
    let cachedItemDirectory = PQGPersistStore.attachmentsCacheDirectory().URLByAppendingPathComponent(fileName).URLByDeletingPathExtension
    createCacheDirIfMissing(cachedItemDirectory)
    
    let cachedPath = cachedItemDirectory.URLByAppendingPathComponent("\(largestSide).\(kind!)")
    if NSFileManager.defaultManager().fileExistsAtPath(cachedPath.path) {
      let cachedImage = UIImage(contentsOfURL: cachedPath)
      return cachedImage
    }
    let original = UIImage(contentsOfURL: filesystemURL!)
    let newCachedImage = original.pqg_scaleAndRotateImage(largestSide)
    let data = UIImageJPEGRepresentation(newCachedImage, 1.0)
    let isWritten = data.writeToURL(cachedPath, atomically: true)
    if !isWritten {
      NSLog("Could not write %@ to %@", fileName!, cachedPath)
    }
    return newCachedImage
  }
}
