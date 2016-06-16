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
    mapView.setUserTrackingMode(.follow, animated: true)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "embeddable" {
      if let tableViewController = segue.destinationViewController as? PQGAddPointTableViewController {
        self.tableViewController = tableViewController
        self.tableViewController.didSelectVenue = { [unowned self] (venue) in
          self.addPointFromFoursquare(venue)
        }
      }
    }
  }
  
  @IBAction func addPointFromMap(_ sender: AnyObject) {
    let del = UIApplication.shared().delegate as! PQGAppDelegate
  
    let point = PQGPoint(store: del.store)
    
    let coordinates = mapView.userTrackingMode == .follow ? mapView.userLocation.coordinate : mapView.centerCoordinate
    
    point.setupAsNewItem(coordinates) { error in
      self.navigationController?.popViewController(animated: true)
      return
    }
  }
  
  func addPointFromFoursquare(_ venue: NSDictionary) {
    let del = UIApplication.shared().delegate as! PQGAppDelegate
    
    let point = PQGPoint(store: del.store)
    
    point.setupFromFoursquareVenue(venue)
    
    _ = self.navigationController?.popViewController(animated: true)
  }

  // MARK: - MapView Delegate
  func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
    switch mode {
    case .follow:
      NSLog("mapView didChangeUserTrackingMode to Follow")
    case .followWithHeading:
      NSLog("mapView didChangeUserTrackingMode to FollowWithHeading")
    case .none:
      NSLog("mapView didChangeUserTrackingMode to None")
    }
  }
  
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    if mapView.userTrackingMode == .follow {
      NSLog("mapView:didUpdateUserLocation: lat \(userLocation.coordinate.latitude) long \(mapView.centerCoordinate.longitude)")
      setCoordinates(userLocation.coordinate)
    } else {
      NSLog("mapView:didUpdateUserLocation: (ignore)")
    }
  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if mapView.userTrackingMode == .none {
      NSLog("FourSquare results should show lat \(mapView.centerCoordinate.latitude) long \(mapView.centerCoordinate.longitude)")
      setCoordinates(mapView.centerCoordinate)
    } else {
      NSLog("mapView:regionDidChangeAnimated: (ignore)")
    }
  }
  
  func setCoordinates(_ location: CLLocationCoordinate2D) {
    mapView.removeAnnotations(mapView.annotations)
    mapView.addAnnotation(PQGLocation(coordinate: location, title: "Point to add"))
    tableViewController.setCoordinates(location)
  }
  
}
