//
//  PQGNSStringUUID.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 2/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

extension NSString {
  
  class func stringWithUUID() -> NSString {
    let uuidObj = CFUUIDCreate(nil)
    let x = CFUUIDCreateString(nil, uuidObj)
    return x as NSString
  }
  
}