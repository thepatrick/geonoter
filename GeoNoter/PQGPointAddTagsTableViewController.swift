//
//  PQGPointAddTagsViewControllerTableViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 29/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGPointAddTagsTableViewController: UITableViewController {
  
  var point : PQGPoint!
  
  var tags = [PQGTag]()
  var chosenTags = Dictionary<Int64, Bool>()

//  override func didReceiveMemoryWarning() {
//    super.didReceiveMemoryWarning()
//  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    reloadData()
  }
  
  func reloadData() {
    self.tags = PQGTag.allInstances() as [PQGTag]
    
    chosenTags.removeAll(keepCapacity: false)
    
    let pointTags = point.tags() as [PQGTag]

    for tag in pointTags {
      chosenTags[tag.id] = true
    }
    self.tableView.reloadData()
  }
  
  // #pragma mark - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    return tags.count
  }

  override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
    let cell = tableView.dequeueReusableCellWithIdentifier("tagCell", forIndexPath: indexPath) as UITableViewCell
    
    let tag = tags[indexPath.row]
    
    cell.textLabel.text = tag.name
    if chosenTags[tag.id] != nil {
      cell.accessoryType = .Checkmark
    } else {
      cell.accessoryType = .None
    }
    
    return cell
  }

  override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    let tag = tags[indexPath.row]
    if chosenTags[tag.id] {
      point.removeTag(tag)
    } else {
      point.addTag(tag)
    }
    reloadData()
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
  }

}
