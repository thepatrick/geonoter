//
//  PQGSettingsTableViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 18/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

//#define GNLocationsDefaultsUseGeocoder     @"LocationsUseGeocoder"
//#define GNLocationsDefaultsDefaultName     @"LocationsDefaultName"
//
//#define GNLocationsDefaultNameMostSpecific @"most-specific"
//#define GNLocationsDefaultNameCoordinates  @"coords"
//#define GNLocationsDefaultNameDateTime     @"datetime"

import UIKit
import MessageUI

enum LocationsDefaultName : String {
  case MostSpecific = "most-specific"
  case Coordinates = "coords"
  case DateTime = "datetime"
  func toString() -> String {
    switch(self) {
    case .MostSpecific:
      return "Most Specific"
    case .Coordinates:
      return "Coordinates"
    case .DateTime:
      return "Date and Time"
    }
  }
  
  static func displayOrder() -> [LocationsDefaultName] {
    return [.MostSpecific, .DateTime, .Coordinates]
  }
}

class PQGSettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

  @IBOutlet var version: UILabel!
  
  @IBOutlet var defaultName: UILabel!
  
  @IBOutlet var useGeocoder: UISwitch!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let infoDictionary = Bundle.main().infoDictionary,
          let bundleVersion = infoDictionary["CFBundleVersion"] as? String else {
      assert(false, "mainBundle().infoDictionary is nil. this is... I don't even...")
    }
    
    version.text = "Version \(bundleVersion)"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    useGeocoder.isOn = UserDefaults.standard().bool(forKey: "LocationsUseGeocoder")
    setDefaultNameLabel()
  }
  
  func setDefaultNameLabel() {
    let wantsDefaultName = UserDefaults.standard().string(forKey: "LocationsDefaultName")
    NSLog("wantsDefaultName = \(wantsDefaultName)")
    if wantsDefaultName == nil {
      NSLog("wantsDefaultName not found")
      defaultName.text = LocationsDefaultName.DateTime.toString()
    } else if let wantedDefaultName = LocationsDefaultName(rawValue: wantsDefaultName!) {
      defaultName.text = wantedDefaultName.toString()
    } else {
      NSLog("wantsDefaultName not found")
      defaultName.text = LocationsDefaultName.DateTime.toString()
    }
  }
  
  @IBAction func useGeocoderChanged(_ sender: AnyObject) {
    UserDefaults.standard().set(useGeocoder.isOn, forKey: "LocationsUseGeocoder")
    let defaultName = UserDefaults.standard().string(forKey: "LocationsDefaultName")
    if !useGeocoder.isOn && defaultName == LocationsDefaultName.MostSpecific.rawValue {
      UserDefaults.standard().setValue(LocationsDefaultName.DateTime.rawValue, forKey: "LocationsDefaultName")
      setDefaultNameLabel()
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "changeDefaultName" {
      let vc = segue.destinationViewController as! PQGDefaultNameTableViewController
      let wantsDefaultName = UserDefaults.standard().string(forKey: "LocationsDefaultName")
      if wantsDefaultName == nil {
        NSLog("wantsDefaultName not found")
        vc.pickedDefualt = LocationsDefaultName.DateTime        
      } else if let wantedDefaultName = LocationsDefaultName(rawValue: wantsDefaultName!) {
        vc.pickedDefualt = wantedDefaultName
      } else {
        NSLog("wantsDefaultName not found")
        vc.pickedDefualt = LocationsDefaultName.DateTime
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0 {
      if !MFMailComposeViewController.canSendMail() {
        UIApplication.shared().openURL(URL(string: "mailto:")!)
      } else {
        let picker = MFMailComposeViewController()
        picker.setSubject("Geonoter Database")
        let path = PQGPersistStore.URLForDocument("geonoter.db")
        let data = try? Data(contentsOf: path)
        picker.addAttachmentData(data!, mimeType: "application/x-sqlite3", fileName: "geonoter.db")
        picker.setToRecipients(["support@thepatrick.io"])
        picker.mailComposeDelegate = self
        present(picker, animated: true, completion: nil)
      }
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: NSError?) {
    dismiss(animated: true, completion: nil)
  }
  

}
