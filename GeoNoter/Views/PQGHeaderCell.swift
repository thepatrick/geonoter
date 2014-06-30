//
//  PQGHeaderCell.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGHeaderCell: UICollectionViewCell {
  
  @IBOutlet var textLabel : UILabel

  @IBOutlet var background : UIView

  var visualEffectView =  UIVisualEffectView(effect: UIBlurEffect(style: .Light))
  
  init(coder: NSCoder?) {
    super.init(coder: coder)
  }
  
  override func awakeFromNib()  {
    background.addSubview(visualEffectView)
  }
  
  override func layoutSubviews() {
    NSLog("layoutSubViews!")
    visualEffectView.frame = background.frame
  }
    
}
