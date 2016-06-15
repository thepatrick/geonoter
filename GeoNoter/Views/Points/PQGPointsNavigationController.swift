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

    if let homeView = self.topViewController as? PQGPointsViewController {
      homeView.datasourceFetchAll = {
        let appDelegate = UIApplication.shared().delegate as! PQGAppDelegate
        return appDelegate.store.points.all
      }
    } else {
      assert(false, "PQGPointsNavigationController topViewController is not a PQGPointsViewController as expected")
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject!) {
    NSLog("prepareForSegue: %@", segue);
  }

}
