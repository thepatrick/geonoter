//
//  PQGMemoEditorViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 12/09/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGMemoEditorViewController: UIViewController, UITextViewDelegate {
  
  var point : PQGPoint!

  @IBOutlet weak var textField: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Memo"

    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
//    let center = NSNotificationCenter.defaultCenter()
//    center.
    
    textField.text = point.memo ?? "No Memo"
    
    textField.becomeFirstResponder()
  
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    NSLog("textField did begin editing, boo!")
  }
  
  func textViewDidChange(textView: UITextView) {
    NSLog("textField did change")
    point.memo = textView.text
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    NSLog("textViewDidEndEditing")
    point.save()
  }
 
}
