//
//  PQGPointAddTagsViewControllerTableViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 29/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGPointAddTagsTableViewController: UITableViewController {
  
  var point : GNPoint!
  
  var tags = [Tag]()
  var chosenTags = Dictionary<Int, Tag>()

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    point.store.tellCacheToDehydrate()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    reloadData()
  }
  
  func reloadData() {
    self.tags = point.store.getAllTags() as [Tag]
    
    chosenTags.removeAll(keepCapacity: false)
    
    let pointTags = point.tags() as Array<Tag>
    for tag in pointTags {
      chosenTags[tag.dbId.integerValue] = tag
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
    if chosenTags[tag.dbId.integerValue] != nil {
      cell.accessoryType = .Checkmark
    } else {
      cell.accessoryType = .None
    }
    
    return cell
  }

  override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    let tag = tags[indexPath.row].hydrate()
    if chosenTags[tag.dbId.integerValue] != nil {
      point.removeTag(tag)
    } else {
      point.addTag(tag)
    }
    reloadData()
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
  }

}
