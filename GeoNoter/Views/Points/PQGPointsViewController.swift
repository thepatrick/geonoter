//
//  PQGPointsViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 10/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGPointsViewController: UITableViewController {
  
  @IBOutlet var addButton : UIBarButtonItem
  
  var datasourceFetchAll : (() -> ([GNPoint]))?
  var datasourceCreatedNewPoint : ((GNPoint) -> ())?
  
  var points = [GNPoint]()

  init(coder: NSCoder?) {
    super.init(coder: coder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Locations"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    reloadData()
  }
  
  func reloadData() {
    if let fetch = datasourceFetchAll {
      self.points = fetch()
    }
    tableView.reloadData()
  }

  // #pragma mark - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1
  }

  override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    return points.count
  }
  
  override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
    let cell = tableView.dequeueReusableCellWithIdentifier("pointCell", forIndexPath: indexPath) as UITableViewCell
    
    let point = self.points[indexPath.row].hydrate()
    
    cell.textLabel.text = point.name
    cell.accessoryType = .DisclosureIndicator
    
    return cell
  }

  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
      // Return NO if you do not want the specified item to be editable.
      return true
  }
  */

  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
      if editingStyle == .Delete {
          // Delete the row from the data source
          tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      } else if editingStyle == .Insert {
          // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
      }    
  }
  */

  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView?, moveRowAtIndexPath fromIndexPath: NSIndexPath?, toIndexPath: NSIndexPath?) {

  }
  */

  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView?, canMoveRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
      // Return NO if you do not want the item to be re-orderable.
      return true
  }
  */

  // #pragma mark - Navigation

  override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    NSLog("prepare for segue %@", segue)
    if segue.identifier == "pushToPointDetail" {
      let pointsDetail = segue.destinationViewController as PQGPointDetailViewController
      let cell = sender as UITableViewCell
      let indexPath = tableView.indexPathForCell(cell)
      pointsDetail.point = points[indexPath.row]
      NSLog("Set point to \(points[indexPath.row])")
    }
  }
  
  /*
  // #pragma mark - Other UI Actions
  */
  
  @IBAction func addPoint(sender : AnyObject) {
    NSLog("addPoint")
    
    let del = UIApplication.sharedApplication().delegate as PQGAppDelegate
    
    let point = GNPoint()
    point.store = del.store
    let addButton = showLoading()
    
    NSLog(">> setupAsNewItem")
    point.setupAsNewItem {
      NSLog("<< setupAsNewItem")
      NSLog("setting back %@", addButton)
      self.navigationItem.rightBarButtonItem = addButton
      self.datasourceCreatedNewPoint?(point)
      // let pd = PointsDetail(point:point andStore: del.store)
      // self.navigationController.pushViewController(pd, animated: true)
      self.reloadData()
    }
  }
  
  func showLoading() -> UIBarButtonItem {
    let previousItem = navigationItem.rightBarButtonItem
    let frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    let loading = UIActivityIndicatorView(frame: frame)
    loading.startAnimating()
    loading.sizeToFit()
    loading.autoresizingMask = (UIViewAutoresizing.FlexibleLeftMargin |
      UIViewAutoresizing.FlexibleRightMargin |
      UIViewAutoresizing.FlexibleTopMargin |
      UIViewAutoresizing.FlexibleBottomMargin
    )
    let loadingView = UIBarButtonItem(customView: loading)
    loadingView.style = .Bordered
    loadingView.target = self
    navigationItem.rightBarButtonItem = loadingView
    return previousItem
  }

}
