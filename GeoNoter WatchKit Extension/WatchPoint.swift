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
  let memo: String?
  let coordinates: CLLocationCoordinate2D?

  init(point: [String: AnyObject]) {
    self.id = (point["id"] as? NSNumber)?.int64Value ?? 0
    self.name = point["name"] as? String ?? "(no name)"
    self.friendlyName = point["friendlyName"] as? String
    self.memo = point["memo"] as? String

    if let location = point["location"] as? [String: NSNumber],
       let lat = location["lat"]?.doubleValue,
       let lng = location["lng"]?.doubleValue {
      self.coordinates = CLLocationCoordinate2DMake(lat, lng)
    } else {
      self.coordinates = nil
    }
  }
}
