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
  
  var tags = Tag[]()
  var chosenTags = Tag[]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

//  -(void)reloadData
//  {
//  GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
//  self.tags = [del.store getAllTags];
//  if(!chosenTags) {
//		chosenTags = [[NSMutableArray arrayWithCapacity:[tags count]] retain];
//		[chosenTags addObjectsFromArray:[point tags]];
//  }
//  [self.dataTable reloadData];
//  }
//  
//  
//  -(void)viewWillAppear:(BOOL)animated
//  {
//  [self reloadData];
//  NSLog(@"tags: %@", tags);
//  }
  
  func reloadData() {
    let myTags = point.store.getAllTags() as Array
    
    
    var intTags : Tag?[] = myTags.map { (object: AnyObject!) -> Tag? in
      nil
    }
    
    
//    for tag in myTags {
//      if let tag = tag as? Tag {
//        intTags += tag
//      }
//    }
  }
  
  // #pragma mark - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0
  }

  override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
    let cell = tableView.dequeueReusableCellWithIdentifier("tagCell", forIndexPath: indexPath) as UITableViewCell

    // Configure the cell...

    return cell
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
