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
    let infoDictionary = NSBundle.mainBundle().infoDictionary as [NSString:AnyObject]
    if let bundleVersion = infoDictionary["CFBundleVersion"] as? NSString {
      version.text = "Version \(bundleVersion)"
    } else {
      version.text = "Version crasp"
      
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    useGeocoder.on = NSUserDefaults.standardUserDefaults().boolForKey("LocationsUseGeocoder")
    setDefaultNameLabel()
  }
  
  func setDefaultNameLabel() {
    let wantsDefaultName = NSUserDefaults.standardUserDefaults().stringForKey("LocationsDefaultName")
    NSLog("wantsDefaultName = \(wantsDefaultName)")
    if wantsDefaultName == nil {
      NSLog("wantsDefaultName not found")
      defaultName.text = LocationsDefaultName.DateTime.toString()
    } else if let wantedDefaultName = LocationsDefaultName.fromRaw(wantsDefaultName!) {
      defaultName.text = wantedDefaultName.toString()
    } else {
      NSLog("wantsDefaultName not found")
      defaultName.text = LocationsDefaultName.DateTime.toString()
    }
  }
  
  @IBAction func useGeocoderChanged(sender: AnyObject) {
    NSUserDefaults.standardUserDefaults().setBool(useGeocoder.on, forKey: "LocationsUseGeocoder")
    let defaultName = NSUserDefaults.standardUserDefaults().stringForKey("LocationsDefaultName")
    if !useGeocoder.on && defaultName == LocationsDefaultName.MostSpecific.toRaw() {
      NSUserDefaults.standardUserDefaults().setValue(LocationsDefaultName.DateTime.toRaw(), forKey: "LocationsDefaultName")
      setDefaultNameLabel()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    if segue.identifier == "changeDefaultName" {
      let vc = segue.destinationViewController as PQGDefaultNameTableViewController
      let wantsDefaultName = NSUserDefaults.standardUserDefaults().stringForKey("LocationsDefaultName")
      if wantsDefaultName == nil {
        NSLog("wantsDefaultName not found")
        vc.pickedDefualt = LocationsDefaultName.DateTime        
      } else if let wantedDefaultName = LocationsDefaultName.fromRaw(wantsDefaultName!) {
        vc.pickedDefualt = wantedDefaultName
      } else {
        NSLog("wantsDefaultName not found")
        vc.pickedDefualt = LocationsDefaultName.DateTime
      }
    }
  }
  
  override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    if indexPath.section == 2 && indexPath.row == 0 {
      if !MFMailComposeViewController.canSendMail() {
        UIApplication.sharedApplication().openURL(NSURL(string: "mailto:"))
      } else {
        let picker = MFMailComposeViewController()
        picker.setSubject("Geonoter Database")
        let path = PQGPersistStore.URLForDocument("geonoter.db")
        let data = NSData(contentsOfURL: path)
        picker.addAttachmentData(data, mimeType: "application/x-sqlite3", fileName: "geonoter.db")
        picker.setToRecipients(["support@thepatrick.io"])
        picker.mailComposeDelegate = self
        presentViewController(picker, animated: true, completion: nil)
      }
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  

}
