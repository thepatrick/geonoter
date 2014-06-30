//
//  PQGPointsNavigationController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 10/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGPointsNavigationController: UINavigationController {
  
  init(coder: NSCoder?) {
    super.init(coder: coder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    NSLog("PQGPointsNavigationController viewDidLoad %@", self.topViewController)

    if let homeView = self.topViewController as? PQGPointsViewController {
      
//      homeView.datasourceCreatedNewPoint = { point in
//        NSLog("Created point %@", point)
//      }
      
      homeView.datasourceFetchAll = {
        if let appDelegate = UIApplication.sharedApplication().delegate as? PQGAppDelegate {
          if let points = appDelegate.store.getAllPoints() as? GNPoint[] {
            return points
          } else {
            assert(false, "appDelegate.store.getAllPoints() was not convertable to GNPoint[].")
          }
        } else {
          assert(false, "UIApplication.sharedApplication().delegate is not a PQGAppDelegate as expected")
        }
        return GNPoint[]()
      }
    } else {
      assert(false, "PQGPointsNavigationController topViewController is not a PQGPointsViewController as expected")
    }
    
    
//    [self.homeView setDatasourceFetchAll:^() {
//    GeoNoterAppDelegate *del = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
//    return (NSArray*)[del.store getAllPoints];
//    }];
//    [self pushViewController:homeView animated:NO];
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    NSLog("prepareForSegue: %@", segue);
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
