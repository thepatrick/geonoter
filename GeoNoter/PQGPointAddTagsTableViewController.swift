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
  var chosenTags = Dictionary<Int64, PQGTag>()

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    point.store.tellCacheToDehydrate()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    reloadData()
  }
  
  func reloadData() {
    
    self.tags = point.store.tags.all
    
    chosenTags.removeAll(keepCapacity: false)
    
    for tag in point.tags {
      chosenTags[tag.primaryKey] = tag
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
    
    let tag = tags[indexPath.row].hydrate()
    
    cell.textLabel.text = tag.name
    if chosenTags[tag.primaryKey] != nil {
      cell.accessoryType = .Checkmark
    } else {
      cell.accessoryType = .None
    }
    
    return cell
  }

  override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    let tag = tags[indexPath.row].hydrate()
    if chosenTags[tag.primaryKey] != nil {
      point.removeTag(tag)
    } else {
      point.addTag(tag)
    }
    reloadData()
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
  }

}
