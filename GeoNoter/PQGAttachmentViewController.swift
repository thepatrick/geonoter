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
  
  let queue = DispatchQueue(label: "cacheQueue", attributes: DispatchQueueAttributes.concurrent)
  
  @IBOutlet var scrollView : UIScrollView!
  var imageView : UIImageView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    title = attachment.friendlyName
    scrollView.zoomScale = 1.0
  }
  
  override func viewDidAppear(_ animated: Bool) {
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
    queue.async {
      let mainScreen = UIScreen.main()
      
      let bounds = mainScreen.bounds
      let largestSide = max(bounds.width, bounds.height) * mainScreen.scale * 2
      let image = attachment?.loadCachedImageForSize(Int(largestSide))
      
      DispatchQueue.main.async {
        let imageView = UIImageView(image: image)
        imageView.frame = self.scrollView.frame
        imageView.contentMode = .scaleAspectFit
        self.scrollView.addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        self.imageView = imageView
        self.calculateScrollViewScale()
        self.scrollView.zoomScale = self.initialZoomLevel
        self.centerScrollViewContents()
      }
    }
  }
  
  func centerScrollViewContents() {
    if let imageView = imageView {
      let boundsSize = scrollView.bounds.size
      let contentsSize = imageView.frame.size
      
      if (contentsSize.width < boundsSize.width) || (contentsSize.height < boundsSize.height) {
        let tempx = imageView.center.x - ( boundsSize.width / 2 )
        let tempy = imageView.center.y - ( boundsSize.height / 2 )
        let myScrollViewOffset = CGPoint( x: tempx, y: tempy)
        scrollView.contentOffset = myScrollViewOffset;
      }
      
      var contentsInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      if contentsSize.width < boundsSize.width {
        contentsInset.left = (boundsSize.width - contentsSize.width) / 2.0
        contentsInset.right = contentsInset.left
      }
      if contentsSize.height < boundsSize.height {
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

  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    centerScrollViewContents()
  }
  
  func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    centerScrollViewContents()
  }
    
  // #pragma mark - Action Button
  
  @IBAction func actionPressed(_ sender : AnyObject) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: actionSheetDeleteMe))
    if MFMailComposeViewController.canSendMail() {
      alert.addAction(UIAlertAction(title: "Email Photo", style: .default, handler: actionSheetSendEmail))
    }
    alert.addAction(UIAlertAction(title: "Save to Camera Roll", style: .default, handler: actionSheetSaveToRoll))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func actionSheetDeleteMe(_ action: UIAlertAction!) {
    attachment.destroy()
    navigationController!.popViewController(animated: true)
  }
  
  func actionSheetSendEmail(_ action: UIAlertAction!) {
    let composer = MFMailComposeViewController()
    composer.mailComposeDelegate = self
    composer.setSubject(attachment.friendlyName!)
    composer.addAttachmentData(attachment.data! as Data, mimeType: "image/jpg", fileName: attachment.fileName!)
    present(composer, animated: true, completion: nil)
  }
  
  func actionSheetSaveToRoll(_ action: UIAlertAction!) {
    ALAssetsLibrary().writeImageData(toSavedPhotosAlbum: attachment.data, metadata: [:]) {
      url, error in
      if let writeError = error {
        let alert = UIAlertController(title: "Your photo could not be saved to the photo roll.", message: writeError.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
    }
  }
  
  // #pragma mark Email stuff

  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: NSError?) {
    controller.dismiss(animated: true, completion: nil)
  }

}
