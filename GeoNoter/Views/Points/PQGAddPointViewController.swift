//
//  PQGAddPointViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 1/09/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit
import MapKit

class PQGAddPointViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  
  weak var tableViewController: PQGAddPointTableViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.setUserTrackingMode(.Follow, animated: true)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "embeddable" {
      if let tableViewController = segue.destinationViewController as? PQGAddPointTableViewController {
        self.tableViewController = tableViewController
      }
    }
  }
  
  @IBAction func addPointFromMap(sender: AnyObject) {
    let del = UIApplication.sharedApplication().delegate as PQGAppDelegate
  
    let point = PQGPoint(store: del.store)
    
    let coordinates = mapView.userTrackingMode == .Follow ? mapView.userLocation.coordinate : mapView.centerCoordinate
    
    point.setupAsNewItem(coordinates) { error in
      self.navigationController?.popViewControllerAnimated(true)
      return
    }
  }

  // MARK: - MapView Delegate
  func mapView(mapView: MKMapView!, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
    switch mode {
    case .Follow:
      NSLog("mapView didChangeUserTrackingMode to Follow")
    case .FollowWithHeading:
      NSLog("mapView didChangeUserTrackingMode to FollowWithHeading")
    case .None:
      NSLog("mapView didChangeUserTrackingMode to None")
    }
  }
  
  func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
    if mapView.userTrackingMode == .Follow {
      NSLog("mapView:didUpdateUserLocation: lat \(userLocation.coordinate.latitude) long \(mapView.centerCoordinate.longitude)")
      setCoordinates(userLocation.coordinate)
    } else {
      NSLog("mapView:didUpdateUserLocation: (ignore)")
    }
  }
  
  func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
    if mapView.userTrackingMode == .None {
      NSLog("FourSquare results should show lat \(mapView.centerCoordinate.latitude) long \(mapView.centerCoordinate.longitude)")
      setCoordinates(mapView.centerCoordinate)
    } else {
      NSLog("mapView:regionDidChangeAnimated: (ignore)")
    }
  }
  
  func setCoordinates(location: CLLocationCoordinate2D) {
    mapView.removeAnnotations(mapView.annotations)
    mapView.addAnnotation(PQGLocation(coordinate: location, title: "Point to add"))
//    tableViewController.setCoordinates(location)
  }
  
}
