//
//  WatchPoint.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 30/03/2015.
//  Copyright (c) 2015 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import CoreLocation

class WatchPoint {
  let id: Int64
  let name: String
  let friendlyName: String?
  let coordinates: CLLocationCoordinate2D?
  let memo: String?
  
  init(point: [String: AnyObject]) {
    if let id = point["id"] as? NSNumber {
      self.id = id.longLongValue
    } else {
      self.id = 0
    }
    if let name = point["name"] as? String {
      self.name = name
    } else {
      self.name = "(no name)"
    }
    if let friendlyName = point["friendlyName"] as? String {
      self.friendlyName = friendlyName
    }
    if let memo = point["memo"] as? String {
      self.memo = memo
    }
    if let location = point["location"] as? [String: NSNumber] {
      if let lat = location["lat"]?.doubleValue {
        if let lng = location["lng"]?.doubleValue {
          self.coordinates = CLLocationCoordinate2DMake(lat, lng)
        }
      }
    }
  }
}