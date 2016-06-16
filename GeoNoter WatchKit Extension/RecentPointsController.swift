//
//  RecentPointsController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 30/03/2015.
//  Copyright (c) 2015 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
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

class RecentPointsController: WKInterfaceController {
  
  @IBOutlet weak var pointTable: WKInterfaceTable!
  @IBOutlet weak var loadingGroup: WKInterfaceGroup!
  @IBOutlet weak var loadingText: WKInterfaceLabel!
  
  override func awake(withContext context: AnyObject?) {
    super.awake(withContext: context)
    
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
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
  var points : [[String: AnyObject]] = []
  
  func getPoints() {
//    WKInterfaceController.openParentApplication([ "watchWants": "recent" ]) { (result, error) in
//      if let _ = error {
//        self.loadingText.setText("Oh oh!")
//      } else if let points = result["points"] as? [[String: AnyObject]] {
//        self.loadingGroup.setHidden(true)
//        self.pointTable.setHidden(false)
//        self.configureTableWithData(points)
//      } else {
//        if let error = result["error"] as? String {
//          self.loadingText.setText(error)
//        } else {
//          self.loadingText.setText("Oh oh!")
//        }
//      }
//    }
    
  }
  
  func configureTableWithData(_ dataObjects: [[String: AnyObject]]) {
    points = dataObjects
    pointTable.setNumberOfRows(dataObjects.count, withRowType: "tagRow")
    for i in 0 ..< pointTable.numberOfRows {
      let row = pointTable.rowController(at: i) as! AddFoursquareRow
      
      if let name = dataObjects[i]["name"] as? String {
        row.textLabel.setText(name)
      } else {
        row.textLabel.setText("panic")
      }
    }
  }
  
  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    let context = WatchPoint(point: points[rowIndex])
    self.pushController(withName: "viewPoint", context: context)
  }
  
}