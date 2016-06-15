//
//  PQGCreditsViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 18/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit

class PQGCreditsViewController: UIViewController {

  @IBOutlet var webView: UIWebView!

  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
  override func viewWillAppear(_ animated: Bool) {
    let credits = Bundle.main().urlForResource("Credits", withExtension: "html")
    webView.loadRequest(URLRequest(url: credits!))
  }

  
}
