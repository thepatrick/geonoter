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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadData()
  }
  
  func reloadData() {
    
    self.tags = point.store.tags.all
    
    chosenTags.removeAll(keepingCapacity: false)
    
    for tag in point.tags {
      chosenTags[tag.primaryKey] = tag
    }
    self.tableView.reloadData()
  }
  
  // #pragma mark - Table view data source

  override func numberOfSections(in tableView: UITableView?) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    return tags.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as UITableViewCell
    
    let tag = tags[(indexPath as NSIndexPath).row].hydrate()
    
    cell.textLabel!.text = tag.name
    if chosenTags[tag.primaryKey] != nil {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let tag = tags[(indexPath as NSIndexPath).row].hydrate()
    if chosenTags[tag.primaryKey] != nil {
      point.removeTag(tag)
    } else {
      point.addTag(tag)
    }
    reloadData()
    tableView.reloadRows(at: [indexPath], with: .none)
  }

}
