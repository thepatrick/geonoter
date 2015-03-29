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
  
  var context: TagPoint!
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    if let contextObject = context as? TagPoint {
      self.context = contextObject
    }
    
    self.name.setText(self.context.name)
    
    if let coordinates = self.context.coordinates {
      let region = MKCoordinateRegionMakeWithDistance(coordinates, 200, 200)
      self.map.addAnnotation(coordinates, withPinColor: .Red)
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
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    NSLog("willActivate AddFoursquareController!")
    
//    loadingGroup.setHidden(false)
//    loadingText.setText("Finding places")
//    pointTable.setHidden(true)
//    
//    getPoints()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
}
