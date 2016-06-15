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
  case deviceDisabled = 1
  case notDetermined, restricted, denied
  
  func description() -> String {
    switch self {
    case .deviceDisabled:
      return "User has disabled location on this device."
    case .notDetermined:
      return "User has not yet approved us for location sharing on this device."
    case .restricted:
      return "Access to location has been restricted on this device."
    case .denied:
      return "User has denied access to location to this application."
    }
  }
  func error() -> NSError {
    return NSError(domain: "LocationHelperError", code: -self.rawValue, userInfo: [
      NSLocalizedDescriptionKey: self.description()
      ])
  }
}


@objc public class LocationHelper: NSObject, CLLocationManagerDelegate {
  
  public class func sharedHelper() -> LocationHelper {
    return GlobalLocationHelperSharedInstance
  }
  
  var locationManager = CLLocationManager()
  var awaitingLocation : Array<((location: CLLocation?, error: NSError?) -> ())>?
  
  public func requestIfNotYetDone() -> NSError? {
    if let error = errorIfDisabled() {
      if error == .notDetermined {
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
      return .deviceDisabled
    }
    switch self.status() {
    case .notDetermined:
      return .notDetermined
    case .restricted:
      return .restricted
    case .denied:
      return .denied
    case .authorizedAlways, .authorizedWhenInUse:
      return nil;
    }
  }
  
  public func location(_ completionHandler: (location: CLLocation?, error: NSError?) -> ()) {
    if let error = errorIfDisabled() {
      DispatchQueue.main.async {
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
  
  public func locationManager(_ manager: CLLocationManager, didUpdate locations: [CLLocation]) {
    let newLocation = locations[0]
    if abs(newLocation.timestamp.timeIntervalSinceNow) < 5.0 {
      NSLog("didUpdateLocations // Received new location info");
      if let completionHandlers = self.awaitingLocation {
        for completionHandler in completionHandlers {
          completionHandler(location: newLocation, error: nil)
        }
      }
    } else {
      NSLog("didUpdateLocations // Received old location info");
    }
  }
  
  public func geocode(_ location : CLLocation, completionHandler: (([CLPlacemark]?, NSError?)->())!) {
    let geo = CLGeocoder()
    geo.reverseGeocodeLocation(location) {
      places, error in
      if error != nil {
        completionHandler(nil, error)
      } else if let placesInternal = places {
        completionHandler(placesInternal, nil)
      } else {
        assert(false, "Error is nil, but places is not an array of CLPlacemark objects, this is quite unexpected");
      }
    }
  }
  
}

let GlobalLocationHelperSharedInstance = LocationHelper()
