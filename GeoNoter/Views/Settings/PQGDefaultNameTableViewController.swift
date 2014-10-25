//
//  PQGDefaultNameTableViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 18/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGDefaultNameTableViewController: UITableViewController {
  
  var pickedDefualt : LocationsDefaultName = LocationsDefaultName.MostSpecific

  let pickList = LocationsDefaultName.displayOrder()
  
//  var defaults = Loc

  // #pragma mark - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
    }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pickList.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("defaultNameCell", forIndexPath: indexPath) as UITableViewCell

    let item = pickList[indexPath.row]
    
    cell.textLabel.text = item.toString()
    
    if item == pickedDefualt {
      cell.accessoryType = .Checkmark
    } else {
      cell.accessoryType = .None
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
    let item = pickList[indexPath.row]
    NSUserDefaults.standardUserDefaults().setValue(item.rawValue, forKey: "LocationsDefaultName")
    navigationController?.popViewControllerAnimated(true)
  }

}
