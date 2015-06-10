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
    
    self.setTitle(self.context.tagName)

    loadingGroup.setHidden(false)
    loadingText.setText("Finding places")
    pointTable.setHidden(true)
    
    getPoints()
    
    // Configure interface objects here.
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
  var points : [[String: AnyObject]] = []
  
  func getPoints() {
    let tagId = NSNumber(longLong: self.context.tagId)
    WKInterfaceController.openParentApplication([ "watchWants": "tagPoints", "tagId": tagId ]) { (result, error) in
      if let err = error {
        self.loadingText.setText("Oh oh!")
        NSLog("watchWants error %@", err)
      } else if let points = result["points"] as? [[String: AnyObject]] {
        self.loadingGroup.setHidden(true)
        self.pointTable.setHidden(false)
        self.configureTableWithData(points)
      } else {
        if let error = result["error"] as? String {
          self.loadingText.setText(error)
        } else {
          self.loadingText.setText("Oh oh!")
        }
      }
    }
  }
  
  func configureTableWithData(dataObjects: [[String: AnyObject]]) {
    points = dataObjects
    pointTable.setNumberOfRows(dataObjects.count, withRowType: "tagRow")
    for var i = 0; i < pointTable.numberOfRows; i++ {
      let row = pointTable.rowControllerAtIndex(i) as! AddFoursquareRow
      
      if let name = dataObjects[i]["name"] as? String {
        row.textLabel.setText(name)
      } else {
        row.textLabel.setText("panic")
      }
    }
  }
  
  override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
    let context = WatchPoint(point: points[rowIndex])
    self.pushControllerWithName("viewPoint", context: context)
  }
  
}
