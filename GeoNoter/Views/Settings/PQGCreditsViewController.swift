//
//  PQGCreditsViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 18/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGCreditsViewController: UIViewController {

  @IBOutlet var webView: UIWebView

  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
  override func viewWillAppear(animated: Bool) {
    let credits = NSBundle.mainBundle().URLForResource("Credits", withExtension: "html")
    webView.loadRequest(NSURLRequest(URL: credits))
  }

  
}
