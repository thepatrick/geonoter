//
//  AddFoursquareVenueController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 29/03/2015.
//  Copyright (c) 2015 Patrick Quinn-Graham. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class AddFoursquareVenueController: WKInterfaceController {
    
  @IBOutlet weak var placeName: WKInterfaceLabel!
  @IBOutlet weak var placeMap: WKInterfaceMap!
  @IBOutlet weak var formattedAddress: WKInterfaceLabel!
  
  @IBOutlet weak var placeMemo: WKInterfaceLabel!
  @IBOutlet weak var placeMemoHint: WKInterfaceLabel!
  
  
  var memo : String?
  
  var context: AddFoursquareVenueContext!
  
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let realContext = context as! AddFoursquareVenueContext
        self.context = realContext
        
        if let name = self.context.place["name"] as? String {
            self.placeName.setText(name)
        }
        
        if let location = self.context.place["location"] as? [NSString: AnyObject] {
          if let coords = coordinateFromLocation(location) {
            let region = MKCoordinateRegionMakeWithDistance(coords, 200, 200)
            self.placeMap.addAnnotation(coords, withPinColor: .Red)
            self.placeMap.setRegion(region)
          } else {
            self.placeMap.setHidden(false)
          }
          if let formattedAddress = location["formattedAddress"] as? [String] {
            let address = formattedAddress.reduce("", combine: { (collect, item) -> String in
              collect + "\n" + item
            })
            self.formattedAddress.setText(address)
          }
        }
        
        NSLog("context %@", self.context.place)
        
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
    
    @IBAction func addPlace() {
      let openDictionary = NSMutableDictionary(dictionary: [ "watchWants": "addFoursquareVenue", "venue": self.context.place ])
      
      if let memo = self.memo {
        openDictionary["memo"] = memo
      }
      
      NSLog("openDictionary %@", openDictionary)
      
      WKInterfaceController.openParentApplication(openDictionary as [NSObject : AnyObject]) { (response, error) -> Void in
            if let err = error {
                NSLog("watchWants error %@", err)
            } else {
                self.context.dismiss(controller: self)
            }
        }
    }
    
    func coordinateFromLocation(location: [NSString: AnyObject]?) -> CLLocationCoordinate2D? {
        if let locationDict = location {
            if let lat = locationDict["lat"] as? NSNumber {
                if let lng = locationDict["lng"] as? NSNumber {
                    return CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue)
                }
            }
        }
        return nil
    }
  
  @IBAction func addMemo() {
    self.presentTextInputControllerWithSuggestions(nil, allowedInputMode: .Plain) { results in
      
      if let result = results?[0] as? String {
        NSLog("addMemo! %@", results!)
        self.memo = result
        self.placeMemo.setText(self.memo)
        self.placeMemo.setHidden(false)
        self.placeMemoHint.setHidden(true)
      }
    }
  }
    
}
