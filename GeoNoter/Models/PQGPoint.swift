//
//  PQGPoint.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 1/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import MapKit
import AddressBookUI
import CoreLocation

class PQGPoint: PQGModel {
  
  override var tableName : String { return "point" }
  
  //MARK: - Private Variables
  private var _pointId:      Int64?
  private var _friendlyName: String?
  private var _name:         String?
  private var _memo:         String?
  private var _recordedAt:   NSDate?
  private var _latitude:     CLLocationDegrees?
  private var _longitude:    CLLocationDegrees?
  
  //MARK: - Public properties
  
  var friendlyName : String? {
  get {
    return hydrate()._friendlyName
  }
  set (newFriendlyName) {
    hydrate()._friendlyName = newFriendlyName
  }
  }
  
  var name : String? {
  get {
    return hydrate()._name
  }
  set (name) {
    hydrate()._name = name
  }
  }
  
  var memo : String? {
  get {
    return hydrate()._memo
  }
  set (memo) {
    hydrate()._memo = memo
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
  
  var latitude : CLLocationDegrees? {
  get {
    return hydrate()._latitude
  }
  set (latitude) {
    hydrate()._latitude = latitude
  }
  }
  
  var longitude : CLLocationDegrees? {
  get {
    return hydrate()._longitude
  }
  set (longitude) {
    hydrate()._longitude = longitude
  }
  }
  
  //MARK: - Lifecycle
  
  override func dehydrate() {
    _pointId = nil
    _friendlyName = nil
    _name = nil
    _memo = nil
    _recordedAt = nil
    _longitude = nil
  }
  
  override func hydrateRequired(row: FMResultSet) {
    _friendlyName = row.stringForColumn("friendly_name")
    _name         = row.stringForColumn("name")
    _memo         = row.stringForColumn("memo")
    _recordedAt   = row.dateForColumn("recorded_at")
    _latitude     = row.doubleForColumn("latitude")
    _longitude    = row.doubleForColumn("longitude")
  }
  
  override func saveForNew(db: FMDatabase) {
    db.executeUpdate("INSERT INTO \(tableName) (id, friendly_name, name, memo, recorded_at, latitude, longitude) " +
      "(?, ?, ?, ?, ?, ?, ?)",
      int64OrNil(primaryKey),
      orNil(friendlyName),
      orNil(name),
      orNil(memo),
      orNil(recordedAt),
      orNil(latitude),
      orNil(longitude)
    )
  }
  
  override func saveForUpdate(db: FMDatabase)  {
    db.executeUpdate("UPDATE \(tableName) SET friendly_name = ?, name = ?, memo = ?, " +
      "recorded_at = ?, latitude = ?, longitude =? WHERE id = ?",
      orNil(friendlyName),
      orNil(name),
      orNil(memo),
      orNil(recordedAt),
      orNil(latitude),
      orNil(longitude),
      int64OrNil(primaryKey)
    )
  }
  
  override func wasDestroyed() {
    store.points.removeCachedObject(primaryKey)
    store.withDatabase { db in
      db.executeUpdate("DELETE FROM point_tag WHERE tag_id = ?",
        self.int64OrNil(self.primaryKey)
      )

      return
    }
    
    for attachment in store.attachments.find.with("point_id = \(primaryKey)").all {
      attachment.destroy()
    }
  }
  
  //MARK: - Tags
  
  var tags : [PQGTag] {
  get {
    let cond = "id IN (select tag_id FROM point_tag WHERE point_id = \(primaryKey))"
    return store.tags.find.with(cond).all
  }
  set (tags) {
    removeAllTags()
    for tag in tags {
      addTag(tag)
    }
  }
  }
  
  func addTag(tag: PQGTag) {
    store.withDatabase { db in
      db.executeUpdate("INSERT INTO point_tag (tag_id, point_id) VALUES (?, ?)",
        self.int64OrNil(self.primaryKey),
        self.int64OrNil(tag.primaryKey)
      )
      return
    }
  }
  
  func removeTag(tag: PQGTag) {
    store.withDatabase { db in
      db.executeUpdate("DELETE FROM point_tag WHERE tag_id = ? AND point_id = ?",
        self.int64OrNil(self.primaryKey),
        self.int64OrNil(tag.primaryKey)
      )
      return
    }
  }
  
  private func removeAllTags() {
    store.withDatabase { db in
      db.executeUpdate("DELETE FROM point_tag WHERE point_id = ?",
        self.int64OrNil(self.primaryKey)
      )
      return
    }
  }
  
  //MARK: - Attachments
  
  var attachments : [PQGAttachment] {
    return store.attachments.find.with("point_id = \(primaryKey)").all
  }
  
  func addAttachment(data: NSData, withExtension: String) -> PQGAttachment {
    let fileName = NSString.stringWithUUID().stringByAppendingPathExtension(withExtension)
    
    let actualFile = PQGPersistStore.attachmentsDirectory().URLByAppendingPathComponent(fileName)
    
    data.writeToURL(actualFile, atomically: true)
    
    let attachment = PQGAttachment(store: store)
    attachment.fileName = fileName
    attachment.kind = withExtension
    attachment.point = self
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .MediumStyle
    dateFormatter.timeStyle = .MediumStyle
    
    let today = NSDate()
    
    attachment.friendlyName = "Picture - \(dateFormatter.stringFromDate(today))"
    attachment.memo = "No memo"
    attachment.recordedAt = today
    attachment.save()
    
    return attachment
  }
  
  //MARK: - Point Helpers
  
  func determineDefaultName(locationName: String?) {
    let defaultName = NSUserDefaults.standardUserDefaults().stringForKey("LocationsDefaultName")
    if defaultName == "most-specific" && !locationName {
      name = locationName
    } else if defaultName == "coords" {
      name = "\(longitude) \(latitude)"
      NSLog("Use lat/long name... \(name)");
    } else {
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateStyle = .MediumStyle
      dateFormatter.timeStyle = .MediumStyle
      name = dateFormatter.stringFromDate(NSDate())
      NSLog("Use date/time name... \(name)");
    }
  }
  
  func setupAsNewItem(completionHandler: (NSError?)->()) {
    PQGLocationHelper.sharedHelper().location { location, error in
      if error {
        NSLog("Oh oh. Could not get location. Should explode")
        completionHandler(error!)
        return
      }
      let coordinate = location!.coordinate
      NSLog("Long! \(coordinate.latitude)")
      NSLog("Lat! \(coordinate.longitude)")
      self.longitude = coordinate.longitude
      self.latitude = coordinate.latitude
      self.name = "Untitled"
      self.friendlyName = "Untitled"
      self.memo = "No memo"
      
      if NSUserDefaults.standardUserDefaults().boolForKey("LocationsUseGeocoder") {
        NSLog("Geocoder time")
        self.geocode { error in
          self.save()
          completionHandler(nil)
        }
      } else {
        NSLog("No geocoder here baby!")
        self.determineDefaultName(nil)
        self.save()
      }
      completionHandler(nil)
    }
  }
  
  var bgTask : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
  
  private func geocode(completionHandler: (NSError?)->()) {
    bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
      if self.bgTask != UIBackgroundTaskInvalid {
        UIApplication.sharedApplication().endBackgroundTask(self.bgTask)
        self.bgTask = UIBackgroundTaskInvalid
      }
    }
    
    let location = CLLocation(latitude: latitude!, longitude: longitude!)
    NSLog("Geocoding \(location)")
    
    PQGLocationHelper.sharedHelper().geocode(location) { placemarks, error in
      UIApplication.sharedApplication().endBackgroundTask(self.bgTask)
      self.bgTask = UIBackgroundTaskInvalid
      if error || placemarks!.count == 0 {
        self.friendlyName = "Geocoder Unavailable"
      } else {
        self.reverseGeocoderDidFindPlacemark(placemarks![0])
      }
      completionHandler(error)
    }
    
  }
  
  private func reverseGeocoderDidFindPlacemark(placemark: CLPlacemark) {
    var simpleName = placemark.country
    
    if placemark.administrativeArea != "" {
      simpleName = placemark.administrativeArea
    }

    if placemark.locality != "" {
      simpleName = placemark.locality
    }

    if placemark.subLocality != "" {
      simpleName = placemark.subLocality
    }

    if placemark.thoroughfare != "" && placemark.subThoroughfare == "" {
      simpleName = placemark.thoroughfare
    }

    if placemark.subThoroughfare != "" && placemark.subThoroughfare != "" {
      simpleName = placemark.subThoroughfare + " " + placemark.thoroughfare
    }

    if placemark.areasOfInterest.count == 1 {
      simpleName = placemark.areasOfInterest[0] as String
    }

    determineDefaultName(simpleName)

    friendlyName = ABCreateStringWithAddressDictionary(placemark.addressDictionary, true)
  }
  
}
