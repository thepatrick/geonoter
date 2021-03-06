//
//  PQGTagsTableViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 14/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGTagsTableViewController: UITableViewController, UITextFieldDelegate {
  
  var tags = [PQGTag]()

  @IBOutlet var newTagName: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func viewWillAppear(animated: Bool) {
    reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // #pragma mark - Tags API
  
  func reloadData() {
    fetchData()
    tableView.reloadData()
  }
  
  var store : PQGPersistStore {
    let appDelegate = UIApplication.sharedApplication().delegate as PQGAppDelegate
    return appDelegate.store
  }
  
  func fetchData() {
    self.tags = store.tags.all
  }
  
  // #pragma mark - Table view delegate
  
  override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return .Delete
  }
  
  // #pragma mark - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tags.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("tagCell", forIndexPath: indexPath) as UITableViewCell
    
    cell.textLabel.text = tags[indexPath.row].hydrate().name
    cell.accessoryType = .DisclosureIndicator;
    
    return cell
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      // Delete the row from the data source
      let tag = self.tags[indexPath.row]
      tag.destroy()
      fetchData()
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
  }
  
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
    return "Tags"
  }
  
  // #pragma mark - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "pushToTagPoints" {
      let vc = segue.destinationViewController as PQGPointsViewController
      let tag = self.tags[tableView.indexPathForSelectedRow()!.row]
      vc.datasourceFetchAll = {
        return tag.points
      }
      vc.datasourceCreatedNewPoint = { point in
        point.addTag(tag)
      }
      vc.title = tag.name
    }
  }

  
  //  #pragma mark - Add Text Field Delegates
  
  func textFieldDidBeginEditing(textField: UITextField!) {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAddTagNow:")
  }
  
  func textFieldShouldReturn(textField: UITextField!) -> Bool {
    PQGTag(name: newTagName.text, store: store).save()
    reloadData()
    cancelAddTagNow(textField)
    return true
  }
  
  func cancelAddTagNow(sender: AnyObject!) {
    self.navigationItem.rightBarButtonItem = self.editButtonItem()
    newTagName.text = ""
    newTagName.resignFirstResponder()
  }
  
}
