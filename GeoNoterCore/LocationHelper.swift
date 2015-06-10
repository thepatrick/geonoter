//
//  LocationHelper.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 29/03/2015.
//  Copyright (c) 2015 Patrick Quinn-Graham. All rights reserved.
//

import UIKit
import CoreLocation

public enum LocationHelperError: Int {
  case DeviceDisabled = 1
  case NotDetermined, Restricted, Denied
  
  func description() -> String {
    switch self {
    case .DeviceDisabled:
      return "User has disabled location on this device."
    case .NotDetermined:
      return "User has not yet approved us for location sharing on this device."
    case .Restricted:
      return "Access to location has been restricted on this device."
    case .Denied:
      return "User has denied access to location to this application."
    }
  }
  func error() -> NSError {
    return NSError(domain: "LocationHelperError", code: -self.rawValue, userInfo: [
      NSLocalizedDescriptionKey: self.description()
      ])
  }
}


public class LocationHelper: NSObject, CLLocationManagerDelegate {
  
  public class func sharedHelper() -> LocationHelper {
    return GlobalLocationHelperSharedInstance
  }
  
  var locationManager = CLLocationManager()
  var awaitingLocation : Array<((location: CLLocation?, error: NSError?) -> ())>?
  
  public func requestIfNotYetDone() -> NSError? {
    if let error = errorIfDisabled() {
      if error == .NotDetermined {
        locationManager.requestWhenInUseAuthorization()
      } else {
        return error.error()
      }
    }
    return nil
  }
  
  public func deviceEnabled() -> Bool {
    return CLLocationManager.locationServicesEnabled()
  }
  
  public func status() -> CLAuthorizationStatus {
    return CLLocationManager.authorizationStatus()
  }
  
  public func errorIfDisabled() -> LocationHelperError? {
    if !deviceEnabled() {
      return .DeviceDisabled
    }
    switch self.status() {
    case .NotDetermined:
      return .NotDetermined
    case .Restricted:
      return .Restricted
    case .Denied:
      return .Denied
    case .AuthorizedAlways, .AuthorizedWhenInUse:
      return nil;
    }
  }
  
  public func location(completionHandler: (location: CLLocation?, error: NSError?) -> ()) {
    if let error = errorIfDisabled() {
      dispatch_async(dispatch_get_main_queue()) {
        NSLog("We can't get location right now: %@", error.description())
        completionHandler(location: nil, error: error.error())
      }
      return;
    }
    
    if var callbacks = awaitingLocation {
      callbacks.append(completionHandler)
    } else {
      self.awaitingLocation = [completionHandler]
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation()
    }
  }
  
  public func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
    self.awaitingLocation = nil
  }
  
  // mark - CoreLocation Interface
  
  public func locationManager(manager: CLLocationManager,
    didUpdateLocations locations: [AnyObject]) {
      let newLocation = locations[0] as! CLLocation
      if(abs(newLocation.timestamp.timeIntervalSinceNow) < 5.0) {
        NSLog("didUpdateLocations // Received new location info");
        if let callbacks = self.awaitingLocation {
          for completionHandler in self.awaitingLocation! {
            completionHandler(location: newLocation, error: nil)
          }
        }
      } else {
        NSLog("didUpdateLocations // Received old location info");
      }
  }
  
  public func geocode(location : CLLocation, completionHandler: (([CLPlacemark]?, NSError?)->())!) {
    let geo = CLGeocoder()
    geo.reverseGeocodeLocation(location) {
      places, error in
      if error != nil {
        completionHandler(nil, error)
      } else if let placesInternal = places as? [CLPlacemark] {
        completionHandler(placesInternal, nil)
      } else {
        assert(false, "Error is nil, but places is not an array of CLPlacemark objects, this is quite unexpected");
      }
    }
  }
  
}

let GlobalLocationHelperSharedInstance = LocationHelper()