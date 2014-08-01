//
//  PQGAttachmentViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 28/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit
import MessageUI
import AssetsLibrary

//@interface PointAttachmentImage : UIViewController<UIScrollViewDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
//  MBProgressHUD *HUD;
//  BOOL firstLoad;
//}

class PQGAttachmentViewController : UIViewController, UIScrollViewDelegate, MFMailComposeViewControllerDelegate {
  
  var attachment : PQGAttachment!
  
  var initialZoomLevel : CGFloat = 0
  
  let queue = dispatch_queue_create("cacheQueue", DISPATCH_QUEUE_CONCURRENT)
  
  @IBOutlet var scrollView : UIScrollView!
  var imageView : UIImageView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
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
  
  
  func loadImage() {
    let attachment = self.attachment
    dispatch_async(queue) {
      let image = attachment.loadCachedImageForSize(1024)
      
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
  
  // #pragma mark - Action Button
  
  @IBAction func actionPressed(sender : AnyObject) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: actionSheetDeleteMe))
    if MFMailComposeViewController.canSendMail() {
      alert.addAction(UIAlertAction(title: "Email Photo", style: .Default, handler: actionSheetSendEmail))
    }
    alert.addAction(UIAlertAction(title: "Save to Camera Roll", style: .Default, handler: actionSheetSaveToRoll))
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func actionSheetDeleteMe(action: UIAlertAction!) {
    attachment.destroy()
    navigationController.popViewControllerAnimated(true)
  }
  
  func actionSheetSendEmail(action: UIAlertAction!) {
    let composer = MFMailComposeViewController()
    composer.mailComposeDelegate = self
    composer.setSubject(attachment.friendlyName)
    composer.addAttachmentData(attachment.data, mimeType: "image/jpg", fileName: attachment.fileName)
    presentViewController(composer, animated: true, completion: nil)
  }
  
  func actionSheetSaveToRoll(action: UIAlertAction!) {
    ALAssetsLibrary().writeImageDataToSavedPhotosAlbum(attachment.data, metadata: [:]) {
      url, error in
      if error != nil {
        let alert = UIAlertController(title: "Your photo could not be saved to the photo roll.", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
      } else {
        NSLog("Saved to %@", url)
      }
    }
  }
  
  // #pragma mark Email stuff

  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }

}