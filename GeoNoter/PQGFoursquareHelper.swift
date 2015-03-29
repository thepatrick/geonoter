//
//  PQGFoursquareHelper.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 27/03/2015.
//  Copyright (c) 2015 Patrick Quinn-Graham. All rights reserved.
//


import UIKit
import CoreLocation

func PQGFoursquareHelperMakeError(code: Int, description: String) -> NSError {
    return NSError(domain: "PQGFoursquareHelper", code: code, userInfo: [NSLocalizedDescriptionKey: description])
}

class PQGFoursquareHelper : NSObject {
    
    var currentSearchOperation : NSOperation?
    var venues : [NSDictionary] = []
    var isLoading = false
    
    func venuesForCoordinates(coordinates: CLLocationCoordinate2D, completion: ([NSDictionary]?, NSError?)->()) {
        if let operation = currentSearchOperation {
            operation.cancel()
            currentSearchOperation = nil
        }
        isLoading = true
        let operation = Foursquare2.venueSearchNearByLatitude(coordinates.latitude, longitude: coordinates.longitude, query: nil, limit: 10, intent: .intentCheckin, radius: nil, categoryId: nil) { (success, variableResult) -> Void in
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
                            completion(venues, nil)
                        } else {
                            completion(nil, PQGFoursquareHelperMakeError(-1, "Unable to get venues"))
                        }
                    } else {
                        completion(nil, PQGFoursquareHelperMakeError(-2, "Unable to get venues"))
                    }
                }
            } else {
                if let error = variableResult as? NSError {
                    completion(nil, error)
                }
            }
        }
        currentSearchOperation = operation
    }
    
}
