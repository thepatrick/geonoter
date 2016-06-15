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
  
  override func viewWillAppear(_ animated: Bool) {
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
    let appDelegate = UIApplication.shared().delegate as! PQGAppDelegate
    return appDelegate.store
  }
  
  func fetchData() {
    self.tags = store.tags.all
  }
  
  // #pragma mark - Table view delegate
  
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .delete
  }
  
  // #pragma mark - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tags.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as UITableViewCell
    
    cell.textLabel!.text = tags[(indexPath as NSIndexPath).row].hydrate().name
    cell.accessoryType = .disclosureIndicator;
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // Delete the row from the data source
      let tag = self.tags[(indexPath as NSIndexPath).row]
      tag.destroy()
      fetchData()
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
    return "Tags"
  }
  
  // #pragma mark - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "pushToTagPoints" {
      let vc = segue.destinationViewController as! PQGPointsViewController
      let tag = self.tags[(tableView.indexPathForSelectedRow! as NSIndexPath).row]
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
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: "cancelAddTagNow:")
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    PQGTag(name: newTagName.text!, store: store).save()
    reloadData()
    cancelAddTagNow(textField)
    return true
  }
  
  func cancelAddTagNow(_ sender: AnyObject!) {
    self.navigationItem.rightBarButtonItem = self.editButtonItem()
    newTagName.text = ""
    newTagName.resignFirstResponder()
  }
  
}
