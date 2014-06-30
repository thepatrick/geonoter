//
//  PQGAttachmentViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 28/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

//@interface PointAttachmentImage : UIViewController<UIScrollViewDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
//  MBProgressHUD *HUD;
//  BOOL firstLoad;
//}
//
//-(void)actionSheetDeleteMe;
//-(void)actionSheetSendEmail;
//-(void)actionSheetSaveToRoll;
//-(void)actionSheetRenameMe;


class PQGAttachmentViewController : UIViewController, UIScrollViewDelegate {
  
  var attachment : GNAttachment!
  
  var initialZoomLevel : Float = 0
  
  let queue = dispatch_queue_create("cacheQueue", DISPATCH_QUEUE_CONCURRENT)
  
  @IBOutlet var scrollView : UIScrollView
  var imageView : UIImageView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    attachment.hydrate()
    title = attachment.friendlyName
    scrollView.zoomScale = 1.0
  }
  
  override func viewDidAppear(animated: Bool) {
    NSLog("Should show loading HUD...")
    //    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    //    [self.view addSubview:HUD];
    //    HUD.delegate = self;
    //    [HUD showWhileExecuting:@selector(loadImage) onTarget:self withObject:nil animated:YES];
    loadImage()
  }
  
  // #pragma mark - Image handling
  
  func loadCachedImage(path: String) -> UIImage {
    let cachedPath = PersistStore.attachmentCacheURL(path.lastPathComponent)
    if NSFileManager.defaultManager().fileExistsAtPath(cachedPath.path) {
      let image = UIImage(contentsOfFileURL: cachedPath)
      NSLog("Loaded %@ from cache %@", path, cachedPath)
      return image
    } else {
      let image = UIImage(contentsOfFile: path)
      NSLog("img: %f x %f", image.size.width, image.size.height)
      let image2 = image.pqg_scaleAndRotateImage(1024)
      NSLog("img: %f x %f", image2.size.width, image2.size.height)
      let data = UIImageJPEGRepresentation(image2, 1.0)
      data.writeToURL(cachedPath, atomically: true)
      NSLog("Wrote %@ to cache %@", path, cachedPath)
      return image2
    }
  }
  
  func loadImage() {
    let full = attachment.filesystemPath()
    
    dispatch_async(queue) {
      let image = self.loadCachedImage(full)
      
      dispatch_async(dispatch_get_main_queue()) {
        let imageView = UIImageView(image: image)
        imageView.frame = self.scrollView.frame
        imageView.contentMode = .ScaleAspectFit
        self.scrollView.addSubview(imageView)
        imageView.userInteractionEnabled = true
        self.imageView = imageView
        self.calculateScrollViewScale()
        self.scrollView.zoomScale = self.initialZoomLevel
        self.centerScrollViewContents()
      }
    }
  }
  
  func centerScrollViewContents() {
    NSLog("centerScrollViewContents!")
    if let imageView = imageView {
      let boundsSize = scrollView.bounds.size
      let contentsSize = imageView.frame.size
      
      if (contentsSize.width < boundsSize.width) || (contentsSize.height < boundsSize.height) {
        let tempx = imageView.center.x - ( boundsSize.width / 2 )
        let tempy = imageView.center.y - ( boundsSize.height / 2 )
        let myScrollViewOffset = CGPoint( x: tempx, y: tempy)
        scrollView.contentOffset = myScrollViewOffset;
        
        NSLog("Need to reset offset?")
      }
      
      var contentsInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      if contentsSize.width < boundsSize.width {
        NSLog("Need side padding!")
        contentsInset.left = (boundsSize.width - contentsSize.width) / 2.0
        contentsInset.right = contentsInset.left
      }
      if contentsSize.height < boundsSize.height {
        NSLog("Need top/bottom padding!")
        contentsInset.top = (boundsSize.height - contentsSize.height) / 2.0
        contentsInset.bottom = contentsInset.top
      }
      scrollView.contentInset = contentsInset
    }
  }
  
  func calculateScrollViewScale() {
    if let size = imageView?.frame.size {
      scrollView.contentSize = size
      let scrollViewFrame = scrollView.frame
      let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
      let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
      let minScale = max(scaleWidth, scaleHeight)
      scrollView.minimumZoomScale = minScale
      scrollView.maximumZoomScale = 10
      initialZoomLevel = minScale
    }
  }
  
  // #pragma mark - ScrollView
  
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView?
  }
  
  func scrollViewDidZoom(scrollView: UIScrollView) {
    centerScrollViewContents()
  }
  
  func scrollViewDidEndZooming(scrollView: UIScrollView, withView view:UIView, atScale scale:Float) {
    centerScrollViewContents()
  }
  
  @IBAction func actionPressed(sender : AnyObject) {
  }
  
}