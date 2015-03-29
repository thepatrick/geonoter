//
//  AddFoursquareVenueContext.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 29/03/2015.
//  Copyright (c) 2015 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import WatchKit

class AddFoursquareVenueContext {
    
    let place: [NSString: AnyObject]
    
    let dismiss: (controller: WKInterfaceController)->()
    
    init (place: [NSString: AnyObject], dismiss: (controller: WKInterfaceController)->()) {
        self.place = place
        self.dismiss = dismiss
    }
    
}