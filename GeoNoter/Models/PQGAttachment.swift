//
//  PQGAttachment.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 1/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

final class PQGAttachment: PQGModel {
  
  override class func tableName() -> String {
    return "attachment"
  }
    
  //MARK: - Private Variables
  
  private var _pointId:      Int64?
  private var _friendlyName: String?
  private var _kind:         String?
  private var _memo:         String?
  private var _fileName:     String?
  private var _recordedAt:   Date?
  
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
  
  var recordedAt : Date? {
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
  
  var filesystemURL : URL? {
  if let fileName = self.fileName {
    return try! PQGPersistStore.attachmentsDirectory().appendingPathComponent(fileName)
    }
    return nil
  }
  
  var data : Data? {
  if let fsURL = filesystemURL {
    return (try? Data(contentsOf: fsURL))
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
  
  override func hydrateRequired(_ row: FMResultSet) {
    _pointId      = row.longLongInt(forColumn: "point_id")
    _friendlyName = row.string(forColumn: "friendly_name")
    _kind         = row.string(forColumn: "kind")
    _memo         = row.string(forColumn: "memo")
    _fileName     = row.string(forColumn: "file_name")
    _recordedAt   = row.date(forColumn: "recorded_at")
  }
  
  override func saveForNew(_ db: FMDatabase) {
    db.executeUpdate("INSERT INTO \(tableName()) (id, point_id, friendly_name, kind, memo, file_name, recorded_at) " +
      "VALUES (?, ?, ?, ?, ?, ?, ?)",
      NSNumber(value: self.primaryKey),
      numberWithInt64(pointId),
      friendlyName ?? NSNull(),
      kind ?? NSNull(),
      memo ?? NSNull(),
      fileName ?? NSNull(),
      recordedAt ?? NSNull()
    )
  }
  
  override func saveForUpdate(_ db: FMDatabase)  {
    db.executeUpdate("UPDATE \(tableName()) SET point_id = ?, friendly_name = ?, kind = ?, " +
      "memo = ?, file_name = ?, recorded_at = ? WHERE id = ?",
      numberWithInt64(pointId),
      friendlyName ?? NSNull(),
      kind ?? NSNull(),
      memo ?? NSNull(),
      fileName ?? NSNull(),
      recordedAt ?? NSNull(),
      NSNumber(value: primaryKey)
    )
  }
  
  override func wasDestroyed() {
    store.attachments.removeCachedObject(primaryKey)
    if let fsURL = filesystemURL {
      do {
        try FileManager.default().removeItem(at: fsURL)
      } catch _ {
      }
      do {
        try FileManager.default().removeItem(at: try! fsURL.appendingPathExtension("cached.jpg"))
      } catch _ {
      }
      //TODO: Remove all cached image for size variants
    }
  }
  
  //MARK: - Attachment helpers
  
  func createCacheDirIfMissing(_ cacheDirectory: URL) {
    let (exists, _) = PQGPersistStore.fileExists(cacheDirectory)
    if !exists {
      do {
        try FileManager.default().createDirectory(atPath: cacheDirectory.path!, withIntermediateDirectories: true, attributes: nil)
      } catch {
        NSLog("Error trying to create directory! \(error)")
      }
    }
  }
  
  func loadCachedImageForSize(_ largestSide: Int) -> UIImage? {
    let cachedItemDirectory = try! (PQGPersistStore.attachmentsCacheDirectory() as NSURL).appendingPathComponent(fileName!)?.deletingPathExtension()
    createCacheDirIfMissing(cachedItemDirectory!)
    
    let cachedPath = try! cachedItemDirectory!.appendingPathComponent("\(largestSide).\(kind!)")
    if FileManager.default().fileExists(atPath: cachedPath.path!) {
      let cachedImage = UIImage(contentsOfFile: cachedPath.path!)
      return cachedImage
    }
    let original = UIImage(contentsOfFile: filesystemURL!.path!)
    let newCachedImage = original!.pqg_scaleAndRotateImage(largestSide)
    let data = UIImageJPEGRepresentation(newCachedImage!, 1.0)
    let isWritten = (try? data!.write(to: cachedPath, options: [.dataWritingAtomic])) != nil
    if !isWritten {
      NSLog("Could not write %@ to %@", fileName!, cachedPath)
    }
    return newCachedImage
  }
}
