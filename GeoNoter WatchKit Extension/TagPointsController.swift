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

class TagPointsContext {
  
  let tagId: Int64
  let tagName: String
  
  init (tagId: Int64, tagName: String) {
    self.tagId = tagId
    self.tagName = tagName
  }
  
}

class TagPoint {
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

class TagPointsController: WKInterfaceController {
  
  @IBOutlet weak var pointTable: WKInterfaceTable!
  @IBOutlet weak var loadingGroup: WKInterfaceGroup!
  @IBOutlet weak var loadingText: WKInterfaceLabel!
  
  var context: TagPointsContext!
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    if let contextObject = context as? TagPointsContext {
      self.context = contextObject
    }

    loadingGroup.setHidden(false)
    loadingText.setText("Finding places")
    pointTable.setHidden(true)
    
    getPoints()
    
    // Configure interface objects here.
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    NSLog("willActivate AddFoursquareController!")
//    
//    if points.count == 0 {
//      loadingGroup.setHidden(false)
//      loadingText.setText("Finding places")
//      pointTable.setHidden(true)
//      
//      getPoints()
//    }
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
  var points : [[String: AnyObject]] = []
  
  func getPoints() {
    NSLog("getPoints()")
    
    let tagId = NSNumber(longLong: self.context.tagId)
    WKInterfaceController.openParentApplication([ "watchWants": "tagPoints", "tagId": tagId ]) { (result, error) in
      if let err = error {
        self.loadingText.setText("Oh oh!")
        NSLog("watchWants error %@", err)
      } else if let points = result?["points"] as? [[String: AnyObject]] {
        self.loadingGroup.setHidden(true)
        self.pointTable.setHidden(false)
        self.configureTableWithData(points)
      } else {
        self.loadingText.setText("Oh oh!")
        NSLog("Something went wrong :( %@", result)
      }
    }
    
  }
  
  func configureTableWithData(dataObjects: [[String: AnyObject]]) {
    points = dataObjects
    pointTable.setNumberOfRows(dataObjects.count, withRowType: "tagRow")
    for var i = 0; i < pointTable.numberOfRows; i++ {
      let row = pointTable.rowControllerAtIndex(i) as AddFoursquareRow
      
      NSLog("this point is %@", dataObjects[i])
      
      if let name = dataObjects[i]["name"] as? String {
        row.textLabel.setText(name)
      } else {
        row.textLabel.setText("panic")
      }
    }
  }
  
  override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
    let context = TagPoint(point: points[rowIndex])
    self.pushControllerWithName("viewPoint", context: context)
  }
  
}
