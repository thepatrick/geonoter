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
  
  override func awake(withContext context: AnyObject?) {
    super.awake(withContext: context)
    // Configure interface objects here.
    
    fetchTagsFromParentApplication()
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
  var tags : [[String: AnyObject]] = []
  
  func fetchTagsFromParentApplication() {
    NSLog("getTags()")
    
    loadingGroup.setHidden(true)
//    loadingText.setText("Finding tags")
//    tagTable.setHidden(true)
    
//    WKInterfaceController.openParentApplication([ "watchWants": "tags" ]) { (result, error) in
//      if let err = error {
//        self.loadingText.setText("Oh oh!")
//        NSLog("watchWants error %@", err)
//      } else if let tags = result["tags"] as? [[String: AnyObject]] {
//        self.loadingGroup.setHidden(true)
//        self.tagTable.setHidden(false)
//        self.configureTableWithData(tags)
//      } else {
//        self.loadingText.setText("Oh oh!")
//        NSLog("Something went wrong :( %@", result)
//      }
//    }
    
  }
  
  func configureTableWithData(_ dataObjects: [[String: AnyObject]]) {
    tags = dataObjects
    tagTable.setNumberOfRows(dataObjects.count, withRowType: "tagRow")
    for i in 0 ..< tagTable.numberOfRows {
      let row = tagTable.rowController(at: i) as! AddFoursquareRow
      if let name = dataObjects[i]["name"] as? String {
        row.textLabel.setText(name)
      } else {
        row.textLabel.setText("panic")
      }
    }
  }
  
  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    let tag = tags[rowIndex]
    let tagId = tag["id"] as! NSNumber
    let tagName = tag["name"] as! String
    let context = TagPointsContext(tagId: tagId.int64Value, tagName: tagName)
    self.pushController(withName: "tagPoints", context: context)
  }
  
}
