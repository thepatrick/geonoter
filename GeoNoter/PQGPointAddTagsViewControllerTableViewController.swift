//
//  PQGPointAddTagsViewControllerTableViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 29/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGPointAddTagsViewControllerTableViewController: UITableViewController {
  
  var point : GNPoint!
  
  var tags = [Tag]()
  var chosenTags = Dictionary<Int, Tag>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    reloadData()
  }
  
  func refreshSourceData() {
    self.tags = point.store.getAllTags() as Array<Tag>
    
    chosenTags.removeAll(keepCapacity: false)
    
    let pointTags = point.tags() as Array<Tag>
    for tag in pointTags {
      chosenTags[tag.dbId.integerValue] = tag
    }
  }
  
  func reloadData() {
    refreshSourceData()
    self.tableView.reloadData()
  }
  
  // #pragma mark - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    // Return the number of rows in the section.
    return tags.count
  }

  override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
    let cell = tableView.dequeueReusableCellWithIdentifier("tagCell", forIndexPath: indexPath) as UITableViewCell

    // Configure the cell...
    
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
    self.reloadData()
    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
  }
  
  /*
  // #pragma mark - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
  }
  */

}
