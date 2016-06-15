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
  
  override func viewWillAppear(_ animated: Bool) {
    reloadData()
    startListening()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    stopListening()
  }
  
  func reloadData() {
    if let fetch = datasourceFetchAll {
      self.points = fetch()
    }
    tableView.reloadData()
  }
    
  func startListening() {
    let del = UIApplication.shared().delegate as! PQGAppDelegate
    NotificationCenter.default().addObserver(self, selector: "addedPoint:", name: "addedPoint", object: del);
  }
  
  func stopListening() {
    let del = UIApplication.shared().delegate as! PQGAppDelegate
    NotificationCenter.default().removeObserver(self, name: "addedPoint" as NSNotification.Name, object: del);
  }
  
  func addedPoint(_ notification: Notification) {
    reloadData();
  }

  //MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView?) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    return points.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "pointCell", for: indexPath) as UITableViewCell
    
    let point = self.points[(indexPath as NSIndexPath).row]
    
    cell.textLabel!.text = point.name
    cell.accessoryType = .disclosureIndicator
    
    return cell
  }

  //MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject!) {
    NSLog("prepare for segue %@", segue)
    if segue.identifier == "pushToPointDetail" {
      let pointsDetail = segue.destinationViewController as! PQGPointDetailViewController
      let cell = sender as! UITableViewCell
      if let indexPath = tableView.indexPath(for: cell) {
        pointsDetail.point = points[(indexPath as NSIndexPath).row]
        NSLog("Set point to \(points[(indexPath as NSIndexPath).row])")
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
    loading.autoresizingMask = ([UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
    )
    let loadingView = UIBarButtonItem(customView: loading)
    loadingView.style = .plain
    loadingView.target = self
    navigationItem.rightBarButtonItem = loadingView
    return previousItem!
  }

}
