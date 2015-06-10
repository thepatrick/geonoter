//
//  AddFoursquareController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 26/03/2015.
//  Copyright (c) 2015 Patrick Quinn-Graham. All rights reserved.
//

import WatchKit
import Foundation
import GeoNoterCore

class AddFoursquareController: WKInterfaceController {

    @IBOutlet weak var placeTable: WKInterfaceTable!
    @IBOutlet weak var loadingGroup: WKInterfaceGroup!
    @IBOutlet weak var loadingText: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
      
      
      loadingGroup.setHidden(false)
      loadingText.setText("Finding you")
      placeTable.setHidden(true)
      
      getPlaces()
      
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("willActivate AddFoursquareController!")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    var places : [[String: AnyObject]] = []
    
    func getPlaces() {
        NSLog("getPlaces()")
        
        let helper = LocationHelper.sharedHelper();
        
        helper.requestIfNotYetDone()
        
        helper.location { (location, error) -> () in
            if let err = error {
                NSLog("error %@", err)
            } else if let loc = location {
                NSLog("lat %f, lng %f", loc.coordinate.latitude, loc.coordinate.longitude)
                helper.stopUpdatingLocation()
                
                let x = [
                    "lat": NSNumber(double: loc.coordinate.latitude),
                    "lng": NSNumber(double: loc.coordinate.longitude)
                ]
                
                self.loadingText.setText("Finding places")
              
                WKInterfaceController.openParentApplication([ "watchWants": "nearbyPlaces", "location": x ]) { (result, error) in
                    if let err = error {
                        self.loadingText.setText("Oh oh!")
                        NSLog("watchWants error %@", err)
                    } else if let places = result["nearbyPlaces"] as? [[String: AnyObject]] {
                        self.loadingGroup.setHidden(true)
                        self.placeTable.setHidden(false)
                        self.configureTableWithData(places)
                    } else {
                        self.loadingText.setText("Oh oh!")
                        NSLog("Something went wrong :( %@", result)
                    }
                }
                
            }
        }
    }
    
    func configureTableWithData(dataObjects: [[String: AnyObject]]) {
        places = dataObjects
        placeTable.setNumberOfRows(dataObjects.count, withRowType: "foursquare-row")
        for var i = 0; i < placeTable.numberOfRows; i++ {
            let row = self.placeTable.rowControllerAtIndex(i) as! AddFoursquareRow
            if let name = dataObjects[i]["name"] as? String {
                row.textLabel.setText(name)
            } else {
                row.textLabel.setText("panic")
            }
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let context = AddFoursquareVenueContext(place: places[rowIndex], dismiss: { controller in
            self.popToRootController()
        })
        self.pushControllerWithName("addFoursquareVenue", context: context)
    }
    
}
