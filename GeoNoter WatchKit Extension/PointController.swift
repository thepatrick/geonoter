//
//  TagPointsController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 29/03/2015.
//  Copyright (c) 2015 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import WatchKit
import CoreLocation


//let id: Int64
//let name: String
//let friendlyName: String?
//let coordinates: CLLocationCoordinate2D?
//let memo: String?

class PointController: WKInterfaceController {
  
  @IBOutlet weak var name: WKInterfaceLabel!
  @IBOutlet weak var friendlyName: WKInterfaceLabel!
  @IBOutlet weak var map: WKInterfaceMap!
  @IBOutlet weak var memo: WKInterfaceLabel!
  
  var context: WatchPoint!
  
  override func awake(withContext context: AnyObject?) {
    super.awake(withContext: context)
    
    if let contextObject = context as? WatchPoint {
      self.context = contextObject
    }

    self.name.setText(self.context.name)
    
    if let coordinates = self.context.coordinates {
      let region = MKCoordinateRegionMakeWithDistance(coordinates, 200, 200)
      self.map.addAnnotation(coordinates, with: .red)
      self.map.setRegion(region)
    }
    
    if let friendlyName = self.context.friendlyName {
      self.friendlyName.setText(friendlyName)
    } else {
      // hide friendly name group
    }
    
    if let memo = self.context.memo {
      self.memo.setText(memo)
    } else {
      // hide the memo
    }
  }
  
  override func willActivate() {
    super.willActivate()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
}
