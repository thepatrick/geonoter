//
//  UIImageSizer2.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 16/6/16.
//  Copyright © 2009-2016 Patrick Quinn-Graham. All rights reserved.
//  Converted from Objective-C, originally written 23/07/2009

import UIKit

extension UIImage {
  
  func pqg_scaleAndRotateImage(maxSize: NSInteger) -> UIImage? {
    
    let maxSizeFloat = CGFloat(maxSize)
    
    guard let imgRef = cgImage else {
      return nil
    }
    
    let width = CGFloat(imgRef.width)
    let height = CGFloat(imgRef.height)
    
    var transform = CGAffineTransform.identity
    var bounds = CGRect(x: 0, y: 0, width: width, height: height)
    
    if width > maxSizeFloat || height > maxSizeFloat {
      let ratio = width / height
      if (ratio > 1) {
        bounds.size.width = maxSizeFloat
        bounds.size.height = bounds.size.width / ratio
      }
      else {
        bounds.size.height = maxSizeFloat
        bounds.size.width = bounds.size.height * ratio
      }
    }
    
    let scaleRatio = bounds.size.width / width
    let imageSize = CGSize(width: width, height: height)

    var boundHeight : CGFloat
    
    switch imageOrientation {
    case .up:
      transform = .identity
    case .upMirrored:
      transform = CGAffineTransform(translationX: imageSize.width, y: 0.0)
        .scaleBy(x: -1.0, y: 1.0)
    case .down:
      transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height)
        .rotate(CGFloat(M_PI))
    case .downMirrored:
      transform = CGAffineTransform(translationX: 0.0, y: imageSize.height)
        .scaleBy(x: 1.0, y: -1.0)
    case .leftMirrored:
      boundHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = boundHeight
      transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width)
        .scaleBy(x: -1.0, y: 1.0)
        .rotate(3.0 * CGFloat(M_PI) / 2.0)
    case .left:
      boundHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = boundHeight
      transform = CGAffineTransform(translationX: 0.0, y: imageSize.width)
        .rotate(3.0 * CGFloat(M_PI) / 2.0)
    case .rightMirrored:
      boundHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = boundHeight
      transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        .rotate(CGFloat(M_PI) / 2.0)
    case .right:
      boundHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = boundHeight
      transform = CGAffineTransform(translationX: imageSize.height, y: 0.0)
        .rotate(CGFloat(M_PI) / 2.0)
    }
    
    UIGraphicsBeginImageContext(bounds.size)
    
    guard let context = UIGraphicsGetCurrentContext() else {
      return nil
    }
    
    if imageOrientation == .right || imageOrientation == .left {
      context.scale(x: -scaleRatio, y: scaleRatio)
      context.translate(x: -height, y: 0)
    } else {
      context.scale(x: scaleRatio, y: -scaleRatio)
      context.translate(x: 0, y: -height)
    }
    
    context.concatCTM(transform)
    
    context.draw(in: CGRect(x: 0, y: 0, width: width, height: height), image: imgRef)
    let imageCopy = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return imageCopy
  }
  
  func pqg_scaleandRotateImageWithMinimimSideLength(minSize: NSInteger) -> UIImage? {
    
    let minSizeFloat = CGFloat(minSize)
    
    guard let imgRef = self.cgImage else {
      return nil
    }
    
    let width = CGFloat(imgRef.width)
    let height = CGFloat(imgRef.height)
    
    var transform = CGAffineTransform.identity
    
    var bounds = CGRect(x: 0, y: 0, width: width, height: height)
    
    if width > minSizeFloat || height > minSizeFloat {
      let ratio = width / height
      if ratio > 1 {
        bounds.size.height = minSizeFloat
        bounds.size.width = minSizeFloat * ratio
      } else {
        bounds.size.width = minSizeFloat
        bounds.size.height = minSizeFloat / ratio
      }
    }
    
    let scaleRatio = bounds.size.width / width
    let imageSize = CGSize(width: width, height: height)
    var boundHeight : CGFloat = 0
    let orient = self.imageOrientation

    switch self.imageOrientation {
    case .up:
      transform = .identity
    case .upMirrored:
      transform = CGAffineTransform(translationX: imageSize.width, y: 0.0)
        .scaleBy(x: -1.0, y: 1.0)
    case .down:
      transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height)
        .rotate(CGFloat(M_PI))
    case .downMirrored:
      transform = CGAffineTransform(translationX: 0.0, y: imageSize.height)
        .scaleBy(x: 1.0, y: -1.0)
    case .leftMirrored:
      boundHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = boundHeight
      transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width)
        .scaleBy(x: -1.0, y: 1.0)
        .rotate(3.0 * CGFloat(M_PI) / 2.0)
    case .left:
      boundHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = boundHeight
      transform = CGAffineTransform(translationX: 0.0, y: imageSize.width)
        .rotate(3.0 * CGFloat(M_PI) / 2.0)
    case .rightMirrored:
      boundHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = boundHeight
      transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        .rotate(CGFloat(M_PI) / 2.0)
    case .right:
      boundHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = boundHeight
      transform = CGAffineTransform(translationX: imageSize.height, y: 0.0)
        .rotate(CGFloat(M_PI) / 2.0)
    }

    UIGraphicsBeginImageContext(bounds.size)
    
    guard let context = UIGraphicsGetCurrentContext() else {
      return nil
    }
    
    if orient == .right || orient == .left {
      context.scale(x: -scaleRatio, y: scaleRatio)
      context.translate(x: -height, y: 0)
    } else {
      context.scale(x: scaleRatio, y: -scaleRatio)
      context.translate(x: 0, y: -height)
    }
    
    context.concatCTM(transform)
    
    context.draw(in: CGRect(x: 0, y: 0, width: width, height: height), image: imgRef)
    
    let imageCopy = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return imageCopy
  }
  
}

