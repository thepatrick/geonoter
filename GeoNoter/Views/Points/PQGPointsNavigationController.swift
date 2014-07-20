//
//  PQGPointsNavigationController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 10/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGPointsNavigationController: UINavigationController {

  override func viewDidLoad() {
    super.viewDidLoad()

    NSLog("PQGPointsNavigationController viewDidLoad %@", self.topViewController)
    
    let homeView = self.topViewController as PQGPointsViewController
    let appDelegate = UIApplication.sharedApplication().delegate as PQGAppDelegate

    homeView.datasourceFetchAll = {
      return PQGPoint.allInstances() as [PQGPoint]
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    NSLog("prepareForSegue: %@", segue);
  }

}
