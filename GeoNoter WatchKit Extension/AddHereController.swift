//
//  AddHereController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 26/03/2015.
//  Copyright (c) 2015 Patrick Quinn-Graham. All rights reserved.
//

import WatchKit
import Foundation

class AddHereController: WKInterfaceController {
    
    @IBOutlet weak var hereMap: WKInterfaceMap!
    @IBOutlet weak var wtf: WKInterfaceButton!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("willActivate AdHereController!")
        hereMap.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(37.7833, 122.4167), 0, 0))
        wtf.setTitle("Add this place")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    @IBAction func addThisPlace() {
        NSLog("Add this place!")
        popToRootController()
    }
}
