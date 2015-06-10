//
//  PQGPointsViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 10/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGPointsViewController: UITableViewController {
  
  @IBOutlet var addButton : UIBarButtonItem!
  
  var datasourceFetchAll : (() -> ([PQGPoint]))?
  var datasourceCreatedNewPoint : ((PQGPoint) -> ())?
  
  var points = [PQGPoint]()

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

  //MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    return points.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("pointCell", forIndexPath: indexPath) as UITableViewCell
    
    let point = self.points[indexPath.row]
    
    cell.textLabel!.text = point.name
    cell.accessoryType = .DisclosureIndicator
    
    return cell
  }

  //MARK: - Navigation

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    NSLog("prepare for segue %@", segue)
    if segue.identifier == "pushToPointDetail" {
      let pointsDetail = segue.destinationViewController as! PQGPointDetailViewController
      let cell = sender as! UITableViewCell
      if let indexPath = tableView.indexPathForCell(cell) {
        pointsDetail.point = points[indexPath.row]
        NSLog("Set point to \(points[indexPath.row])")
      }
    }
  }
  
  //MARK: - Other UI Actions
    
  func showLoading() -> UIBarButtonItem {
    let previousItem = navigationItem.rightBarButtonItem
    let frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    let loading = UIActivityIndicatorView(frame: frame)
    loading.startAnimating()
    loading.sizeToFit()
    loading.autoresizingMask = ([UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
    )
    let loadingView = UIBarButtonItem(customView: loading)
    loadingView.style = .Plain
    loadingView.target = self
    navigationItem.rightBarButtonItem = loadingView
    return previousItem!
  }

}
