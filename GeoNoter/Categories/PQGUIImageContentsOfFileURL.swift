//
//  PQGUIImageContentsOfFileURL.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 2/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

extension UIImage {
  
  convenience init(contentsOfURL: NSURL) {
    return self.init(contentsOfFile: contentsOfURL.path!)
  }
  
}