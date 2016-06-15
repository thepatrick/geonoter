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

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pickList.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "defaultNameCell", for: indexPath) as UITableViewCell

    let item = pickList[(indexPath as NSIndexPath).row]
    
    cell.textLabel!.text = item.toString()
    
    if item == pickedDefualt {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
    let item = pickList[(indexPath as NSIndexPath).row]
    UserDefaults.standard().setValue(item.rawValue, forKey: "LocationsDefaultName")
    navigationController?.popViewController(animated: true)
  }

}
