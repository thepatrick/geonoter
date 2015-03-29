//
//  TagsController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 29/03/2015.
//  Copyright (c) 2015 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import WatchKit

class TagsController: WKInterfaceController {
  
  @IBOutlet weak var tagTable: WKInterfaceTable!
  @IBOutlet weak var loadingGroup: WKInterfaceGroup!
  @IBOutlet weak var loadingText: WKInterfaceLabel!
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    // Configure interface objects here.
  }
    
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    NSLog("willActivate AddFoursquareController!")
    
    loadingGroup.setHidden(false)
    loadingText.setText("Finding tags")
    tagTable.setHidden(true)
    
    getTags()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
  var tags : [[String: AnyObject]] = []
  
  func getTags() {
    NSLog("getTags()")
        
    WKInterfaceController.openParentApplication([ "watchWants": "tags" ]) { (result, error) in
      if let err = error {
        self.loadingText.setText("Oh oh!")
        NSLog("watchWants error %@", err)
      } else if let tags = result?["tags"] as? [[String: AnyObject]] {
        self.loadingGroup.setHidden(true)
        self.tagTable.setHidden(false)
        self.configureTableWithData(tags)
      } else {
        self.loadingText.setText("Oh oh!")
        NSLog("Something went wrong :( %@", result)
      }
    }
    
  }
  
  func configureTableWithData(dataObjects: [[String: AnyObject]]) {
    tags = dataObjects
    tagTable.setNumberOfRows(dataObjects.count, withRowType: "tagRow")
    for var i = 0; i < tagTable.numberOfRows; i++ {
      let row = tagTable.rowControllerAtIndex(i) as AddFoursquareRow
      if let name = dataObjects[i]["name"] as? String {
        row.textLabel.setText(name)
      } else {
        row.textLabel.setText("panic")
      }
    }
  }
  
  override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
//    let context = AddFoursquareVenueContext(place: tags[rowIndex], dismiss: { controller in
//      controller.dismissController()
//      self.dismissController()
//    })
//    self.presentControllerWithName("addFoursquareVenue", context: context)
  }
  
}
