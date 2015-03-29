//
//  InterfaceController.swift
//  GeoNoter WatchKit Extension
//
//  Created by Patrick Quinn-Graham on 26/03/2015.
//  Copyright (c) 2015 Patrick Quinn-Graham. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("willActivate!")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
