//
//  PQGMemoEditorViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 12/09/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGMemoEditorViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var textField: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    let center = NSNotificationCenter.defaultCenter()
//    center.
    
    textField.becomeFirstResponder()
  
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textFieldDidBeginEditing(textField: UITextField) {
    
  }
  
}
