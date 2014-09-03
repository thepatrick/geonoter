//
//  PQGTagsViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 14/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGTagsViewController: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSLog("PQGPointsNavigationController viewDidLoad %@", self.topViewController)
    
    if let homeView = self.topViewController as? PQGTagsTableViewController {
    } else {
      assert(false, "PQGPointsNavigationController topViewController is not a PQGPointsViewController as expected")
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    NSLog("prepareForSegue: %@", segue);
  }

}
