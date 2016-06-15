//
//  PQGAddPointTableViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 1/09/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit
import CoreLocation

class PQGAddPointTableViewController: UITableViewController {
  
  var didSelectVenue : ((NSDictionary)->())?
  
  var isLoading : Bool = true {
    didSet {
      tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    if section == 0 {
      if isLoading {
        return 1
      } else {
        return venues.count
      }
    } else {
      return 1
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath as NSIndexPath).section == 0 {
      if isLoading {
        let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as UITableViewCell
        return cell
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as UITableViewCell
        
        if let name = venues[(indexPath as NSIndexPath).row]["name"] as? String {
          cell.textLabel!.text = name
        } else {
          cell.textLabel!.text = "Venue \((indexPath as NSIndexPath).row)"
        }
        
        return cell
      }
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "poweredByFoursquare", for: indexPath) as UITableViewCell
      return cell
    }
  }
  
  // MARK: - Table view delegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let x = venues[(indexPath as NSIndexPath).row]
    NSLog("didSelectRowAtIndexPath \(x)")
    didSelectVenue?(x)
  }
  
  // MARK: - FourSquare API
  
  var currentSearchOperation : Operation?
  var venues : [NSDictionary] = []
  
  
  func setCoordinates(_ coordinates: CLLocationCoordinate2D) {
    if let operation = currentSearchOperation {
      operation.cancel()
      currentSearchOperation = nil
    }
    isLoading = true
    let operation = Foursquare2.venueSearchNear(byLatitude: coordinates.latitude, longitude: coordinates.longitude, query: nil, limit: 10, intent: FoursquareIntentType(), radius: nil, categoryId: nil) { (success, variableResult) -> Void in
      self.isLoading = false
      if success {
//        NSLog("Search worked :) \(variableResult)")
        if let result = variableResult as? NSDictionary {
          if let meta = result["meta"] as? NSDictionary {
            if let code = meta["code"] as? Int {
              if code != 200 {
                NSLog("Code is not the expected 200! It is \(code)");
                return;
              }
            }
          }
          if let response = result["response"] as? NSDictionary {
            if let venues = response["venues"] as? [NSDictionary] {
              self.venues = venues
              self.tableView.reloadData()
            } else {
              NSLog("Unable to get venues from \(response)")
            }
          } else {
            NSLog("Unable to get response from \(result)")
          }
        }
      } else {
        if let error = variableResult as? NSError {
          let alert = UIAlertController(title: "Unable to search for locations", message: error.localizedDescription, preferredStyle: .alert)
          self.present(alert, animated: true, completion: nil)
        }
      }
    }
    currentSearchOperation = operation
  }

}
