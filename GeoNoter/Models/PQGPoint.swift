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
import GeoNoterCore

final class PQGPoint: PQGModel {
  
  override class func tableName() -> String {
    return "point"
  }
  
  //MARK: - Private Variables
  private var _pointId:      Int64?
  private var _friendlyName: String?
  private var _name:         String?
  private var _memo:         String?
  private var _recordedAt:   Date?
  private var _latitude:     CLLocationDegrees?
  private var _longitude:    CLLocationDegrees?
  private var _foursquareId: String?
  
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
  
  var recordedAt : Date? {
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
  
  var location: CLLocation? {
    get {
      if let lat = self.latitude {
        if let lng = self.longitude {
          return CLLocation(latitude: lat, longitude: lng)
        }
      }
      return nil
    }
    set (location) {
      if let coordinate = location?.coordinate {
        self.longitude = coordinate.longitude
        self.latitude = coordinate.latitude
      } else {
        self.longitude = nil
        self.latitude = nil
      }
    }
  }
  
  var foursquareId : String? {
    get {
      return hydrate()._foursquareId
    }
    set (foursquareId) {
      hydrate()._foursquareId = foursquareId
    }
  }
  
  var serializedForWatch: [NSString: AnyObject] {
    get {
      _ = hydrate()
      let id = NSNumber(value: primaryKey)
      
      var serialized = [
        "id": id,
        "name": name ?? "(no name)",
        "friendlyName": friendlyName ?? "",
        "memo": memo ?? ""
      ]
      
      if let location = location {
        serialized["location"] = [
          "lat": location.coordinate.latitude,
          "lng": location.coordinate.longitude
        ]
      }
      
      return serialized
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
    _foursquareId = nil
  }
  
  override func hydrateRequired(_ row: FMResultSet) {
    _friendlyName = row.string(forColumn: "friendly_name")
    _name         = row.string(forColumn: "name")
    _memo         = row.string(forColumn: "memo")
    _recordedAt   = row.date(forColumn: "recorded_at")
    _latitude     = row.double(forColumn: "latitude")
    _longitude    = row.double(forColumn: "longitude")
    _foursquareId = row.string(forColumn: "foursqure_venue_id")
  }
  
  override func saveForNew(_ db: FMDatabase) {
    if recordedAt == nil {
      recordedAt = Date()
    }
    let lat = numberWithDouble(latitude) ?? NSNull()
    let lon = numberWithDouble(longitude) ?? NSNull()    
    NSLog("saveForNew recordedAt \(recordedAt)")
    db.executeUpdate("INSERT INTO \(tableName())  (id, friendly_name, name, memo, recorded_at, latitude, longitude, foursqure_venue_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
      NSNumber(value: primaryKey),
      friendlyName ?? NSNull(),
      name ?? NSNull(),
      memo ?? NSNull(),
      recordedAt ?? NSNull(),
      lat,
      lon,
      foursquareId ?? NSNull()
    )
  }
  
  override func saveForUpdate(_ db: FMDatabase)  {
    let lat = numberWithDouble(latitude) ?? NSNull()
    let lon = numberWithDouble(longitude) ?? NSNull()
    db.executeUpdate("UPDATE \(tableName()) SET friendly_name = ?, name = ?, memo = ?, " +
      "recorded_at = ?, latitude = ?, longitude = ?, foursqure_venue_id = ? WHERE id = ?",
      friendlyName ?? NSNull(),
      name ?? NSNull(),
      memo ?? NSNull(),
      recordedAt ?? NSNull(),
      lat,
      lon,
      foursquareId ?? NSNull(),
      NSNumber(value: primaryKey)
    )
  }
  
  override func wasDestroyed() {
    store.points.removeCachedObject(primaryKey)
    store.withDatabase { db in
      db.executeUpdate("DELETE FROM point_tag WHERE tag_id = ?", NSNumber(value: self.primaryKey))

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
  
  func addTag(_ tag: PQGTag) {
    store.withDatabase { db in
      db.executeUpdate("INSERT INTO point_tag (point_id, tag_id) VALUES (?, ?)",
        NSNumber(value: self.primaryKey),
        NSNumber(value: tag.primaryKey)
      )
      return
    }
  }
  
  func removeTag(_ tag: PQGTag) {
    store.withDatabase { db in
      db.executeUpdate("DELETE FROM point_tag WHERE point_id = ? AND tag_id = ?",
        NSNumber(value: self.primaryKey),
        NSNumber(value: tag.primaryKey)
      )
      return
    }
  }
  
  private func removeAllTags() {
    store.withDatabase { db in
      db.executeUpdate("DELETE FROM point_tag WHERE point_id = ?",
        NSNumber(value: self.primaryKey)
      )
      return
    }
  }
  
  //MARK: - Attachments
  
  var attachments : [PQGAttachment] {
    return store.attachments.find.with("point_id = \(primaryKey)").all
  }
  
  func addAttachment(_ data: Data, withExtension fileExtension: String) -> PQGAttachment {
    let fileName = UUID().uuidString.appendingFormat(".%@", fileExtension)
    
    let actualFile = try! PQGPersistStore.attachmentsDirectory().appendingPathComponent(fileName)
    
    try? data.write(to: actualFile, options: [.dataWritingAtomic])
    
    let attachment = PQGAttachment(store: store)
    attachment.fileName = fileName
    attachment.kind = fileExtension
    attachment.point = self
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .mediumStyle
    dateFormatter.timeStyle = .mediumStyle
    
    let today = Date()
    
    attachment.friendlyName = "Picture - \(dateFormatter.string(from: today))"
    attachment.memo = "No memo"
    attachment.recordedAt = today
    attachment.save()
    
    return attachment
  }
  
  //MARK: - Point Helpers
  
  func determineDefaultName(_ locationName: String?) {
    let defaultName = UserDefaults.standard().string(forKey: "LocationsDefaultName")
    if defaultName == "most-specific" && locationName != nil {
      name = locationName
    } else if defaultName == "coords" {
      name = "\(longitude) \(latitude)"
      NSLog("Use lat/long name... \(name)");
    } else {
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .mediumStyle
      dateFormatter.timeStyle = .mediumStyle
      name = dateFormatter.string(from: Date())
      NSLog("Use date/time name... \(name)");
    }
  }
  
  func setupFromFoursquareVenue(_ venue: NSDictionary) {
    
    if let name = venue["name"] as? String {
      self.name = name
    } else {
      // TODO: Error
      return
    }
    
    if let location = venue["location"] as? NSDictionary {
      
      if let longitude = location["lng"] as? NSNumber {
        self.longitude = longitude.doubleValue
      }
      
      if let latitude = location["lat"] as? NSNumber {
        self.latitude = latitude.doubleValue
      }
      
      if let address = location["formattedAddress"] as? NSArray {
        var addressString = ""
        for line in address {
          if let addressLine = line as? String {
            addressString = addressString + "\n" + addressLine
          }
        }
        self.friendlyName = addressString
      }
      
    } else {
      // TODO: Error
      return
    }
    
    if let memo = venue["url"] as? String {
      self.memo = memo
    } else {
      self.memo = "No memo"
    }
    
    self.save()
  }
  
  func setupAsNewItem(_ coordinate: CLLocationCoordinate2D, completionHandler: (NSError?)->()) {
    NSLog("Long! \(coordinate.latitude)")
    NSLog("Lat! \(coordinate.longitude)")
    self.longitude = coordinate.longitude
    self.latitude = coordinate.latitude
    self.name = "Untitled"
    self.friendlyName = "Untitled"
    self.memo = "No memo"
    
    if UserDefaults.standard().bool(forKey: "LocationsUseGeocoder") {
      NSLog("Geocoder time")
      self.geocode { error in
        self.save()
        completionHandler(nil)
      }
    } else {
      NSLog("No geocoder here baby!")
      self.determineDefaultName(nil)
      self.save()
      completionHandler(nil)
    }
  }
  
  var bgTask : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
  
  private func geocode(_ completionHandler: (NSError?)->()) {
    bgTask = UIApplication.shared().beginBackgroundTask {
      if self.bgTask != UIBackgroundTaskInvalid {
        UIApplication.shared().endBackgroundTask(self.bgTask)
        self.bgTask = UIBackgroundTaskInvalid
      }
    }
    
    let location = CLLocation(latitude: latitude!, longitude: longitude!)
    NSLog("Geocoding \(location)")
    
    LocationHelper.sharedHelper().geocode(location) { placemarks, error in
      UIApplication.shared().endBackgroundTask(self.bgTask)
      self.bgTask = UIBackgroundTaskInvalid
      if error != nil || placemarks!.count == 0 {
        self.friendlyName = "Geocoder Unavailable"
      } else {
        self.reverseGeocoderDidFindPlacemark(placemarks![0])
      }
      completionHandler(error)
    }
    
  }
  
  private func reverseGeocoderDidFindPlacemark(_ placemark: CLPlacemark) {
    var simpleName = ""
   
     func setIf(_ x: String?) -> Bool {
      if let unwrapped = x {
        if unwrapped != "" {
          simpleName = unwrapped
          return true
        }
      }
      return false
    }
    
    setIf(placemark.country)
    setIf(placemark.administrativeArea)
    setIf(placemark.locality)
    setIf(placemark.subLocality)
    
    if setIf(placemark.thoroughfare) {
      if setIf(placemark.subThoroughfare) {
        simpleName = placemark.subThoroughfare! + " " + placemark.thoroughfare!
      }
    }

    if placemark.areasOfInterest != nil && placemark.areasOfInterest?.count == 1 {
      setIf(placemark.areasOfInterest?[0])
    }

    determineDefaultName(simpleName)

    friendlyName = ABCreateStringWithAddressDictionary(placemark.addressDictionary!, true)

  }
  
}
