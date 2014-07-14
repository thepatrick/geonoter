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

    if let homeView = self.topViewController as? PQGPointsViewController {
      
//      homeView.datasourceCreatedNewPoint = { point in
//        NSLog("Created point %@", point)
//      }
      
      homeView.datasourceFetchAll = {
        if let appDelegate = UIApplication.sharedApplication().delegate as? PQGAppDelegate {
          if let points = appDelegate.store.getAllPoints() as? [GNPoint] {
            return points
          } else {
            assert(false, "appDelegate.store.getAllPoints() was not convertable to GNPoint[].")
          }
        } else {
          assert(false, "UIApplication.sharedApplication().delegate is not a PQGAppDelegate as expected")
        }
        return [GNPoint]()
      }
    } else {
      assert(false, "PQGPointsNavigationController topViewController is not a PQGPointsViewController as expected")
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    NSLog("prepareForSegue: %@", segue);
  }

}
