//
//  PQGPointDetailViewController.swift
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

import UIKit
import MapKit

let reuseIdentifier = "Cell"

extension UIFont {
  func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
    return NSString(string: string).boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
      options: NSStringDrawingOptions.UsesLineFragmentOrigin,
      attributes: [NSFontAttributeName: self],
      context: nil).size
  }
}

class  PQGLocation : NSObject, MKAnnotation {

  var coordinate : CLLocationCoordinate2D
  var title: String
  
  init(coordinate: CLLocationCoordinate2D, title: String) {
    self.coordinate = coordinate
    self.title = title
    super.init()
  }
  
}

class PQGPointDetailViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var sectionNames = ["Map", "Details", "Tags", "Attachments"]
  
  var headerNib = UINib(nibName: "PQGPointDetailHeader", bundle: nil)

  var store: PQGPersistStore!
  
  private var tagCache: [PQGTag]?
  private var attachmentCache: [PQGAttachment]?

  var point: PQGPoint! {
  didSet {
    self.store = point.store
  }
  }
  
  var tags: [PQGTag] {
    if tagCache == nil {
      tagCache = point.tags
    }
    return tagCache!
  }
  
  var attachments: [PQGAttachment] {
    if attachmentCache == nil {
      attachmentCache = point.attachments
    }
    return attachmentCache!
  }
  
  //MARK: - View Controller life cycle

  override func viewDidLoad() {
    assert(self.point != nil, "viewDidLoad with no point!")

    super.viewDidLoad()
    
    self.title = point.name
  }
  
  override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
    self.reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    point.hydrate()
    NSLog("point friendlyName \(point.friendlyName)")
    reloadData()
  }
  
  func reloadData() {
    tagCache = nil
    attachmentCache = nil
    collectionView.reloadData()
  }
  
  //MARK: - Cell methods
  
  func cellForMapRow(indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("mapCell", forIndexPath: indexPath) as PQGPointDetailHeader

    NSLog("Header section for CSStickyHeaderParallaxHeader")
    let coordinate = CLLocationCoordinate2D(latitude: point.latitude!, longitude: point.longitude!)
    let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
    cell.mapView.setRegion(region, animated: false)
    if cell.mapView.annotations.count == 0 {
        cell.mapView.addAnnotation(PQGLocation(coordinate: coordinate, title: point.name!))
    }    
    return cell
  }
  
  func cellForDetailsRow(indexPath: NSIndexPath) -> UICollectionViewCell {
    let cellIdentifier = indexPath.row < 2 ? "multilineCell" : "cell"
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as PQGCell

    cell.textLabel.text = sectionNames[indexPath.section]
    cell.textLabel.textColor = UIColor.blackColor()
    
    switch indexPath.row {
    case 0:
      cell.textLabel.text = point.friendlyName?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) ?? ""
    case 1:
      cell.textLabel.text = point.memo ?? "No memo"
      if cell.textLabel.text == "No memo" {
        cell.textLabel.textColor = UIColor.lightGrayColor()
      }
    case 2:
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateStyle = .MediumStyle
      dateFormatter.timeStyle = .MediumStyle
      if let recordedAt = point.recordedAt {
        cell.textLabel.text = dateFormatter.stringFromDate(recordedAt)
      } else {
        cell.textLabel.text = "Missing recordedAt"
      }
    case 3:
      if let lat = point.latitude {
        if let lng = point.longitude {
          cell.textLabel.text = "\(lat), \(lng)"
        }
      }
    default:
      assert(false, "Unexpected row count in cellForDetailsRow")
    }
    
    return cell
  }
  
  func cellForTagRow(indexPath: NSIndexPath) -> UICollectionViewCell {
    if tags.count == 0 {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("chooseTagsCell", forIndexPath: indexPath) as PQGCell
      cell.textLabel.text = "Tap to choose tags"
      cell.textLabel.textColor = UIColor.darkGrayColor()
      return cell
    } else {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("tagCell", forIndexPath: indexPath) as PQGCell
      let tag = tags[indexPath.row].hydrate()
      cell.textLabel.text = tag.name
      cell.textLabel.textColor = UIColor.blackColor()
      return cell
    }
  }
  
  func cellForAttachmentsRow(indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("attachmentCell", forIndexPath: indexPath) as PQGCell
    
    cell.textLabel.text = attachments[indexPath.row].hydrate().friendlyName
    cell.textLabel.textColor = UIColor.blackColor()

    return cell
  }
  
  //MARK: - CollectionView delegate/datasource methods
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return attachments.count > 0 ? 4 : 3
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return 3
    case 2:
      return tags.count == 0 ? 1 : tags.count
    case 3:
      return attachments.count
    default:
      return 0
    }
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    switch indexPath.section {
    case 0:
      return cellForMapRow(indexPath)
    case 1:
      return cellForDetailsRow(indexPath)
    case 2:
      return cellForTagRow(indexPath)
    default:
      return cellForAttachmentsRow(indexPath)
    }
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section < 2 {
      return CGSizeMake(0, 0)
    } else {
      return CGSizeMake(collectionView.bounds.size.width, 50)
    }
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    NSLog("Header section for %@", sectionNames[indexPath.section])
    let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "sectionHeader", forIndexPath: indexPath) as PQGCell
    if indexPath.section == 0 {
      cell.textLabel.text = point.name
    } else {
      cell.textLabel.text = sectionNames[indexPath.section]
    }
    return cell
  }
  
  
  func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
    var w = collectionView.frame.width
    var h : CGFloat = 46.0
    
    if indexPath.section == 0 {
      h = 200
    } else  if collectionView.traitCollection.horizontalSizeClass != .Compact {
      w = 320
    }
    
    if indexPath.section == 1 && indexPath.row == 0 {
      if let friendlyName = point.friendlyName?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
        let f = UIFont.systemFontOfSize(17.0)
        h = f.sizeOfString(friendlyName, constrainedToWidth: Double(w) - 40).height + 25
      }
    }
    
    return CGSize(width: w, height: h)
  }
  
  func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    NSLog("didSelectItemAtIndexPath %@", indexPath)
  }
  
  //MARK: - MapViewDelegate
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    var pin = mapView.dequeueReusableAnnotationViewWithIdentifier("standardPin") as? MKPinAnnotationView
    
    if pin == nil {
      pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "standardPin")
    } else {
      pin!.annotation = annotation
    }
    pin!.animatesDrop = false

    return pin
  }
  
  //MARK: - UIImagePickerControllerDelegate
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
    NSLog("Good news, the image picker went away!")
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
    let image = info[UIImagePickerControllerOriginalImage] as UIImage
    let data = UIImageJPEGRepresentation(image, 1.0)
    
    let attachment = self.point.addAttachment(data, withExtension: "jpg")
    
    NSLog("attachment %@", attachment)
    
    picker.dismissViewControllerAnimated(true, completion: nil)
    reloadData()
  }
  
  //MARK: - Action Button
  
  @IBAction func actionButtonPressed(sender: UIBarButtonItem) {
    let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    sheet.addAction(UIAlertAction(title: "Delete Point", style: UIAlertActionStyle.Destructive, handler: deletePoint))
    sheet.addAction(UIAlertAction(title: "Manage Tags", style: UIAlertActionStyle.Default, handler: manageTags))
    
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      sheet.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: takePhoto))
    }
    
    if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
      sheet.addAction(UIAlertAction(title: "Add Existing Photo", style: UIAlertActionStyle.Default, handler: addPhoto))
    }
    
    sheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
    self.presentViewController(sheet, animated: true, completion: nil)
  }
  
  func manageTags(action: UIAlertAction!) {
    performSegueWithIdentifier("editTagsSegue", sender: self)
  }
  
  func takePhoto(action: UIAlertAction!) {
    let picker = UIImagePickerController()
    picker.sourceType = .Camera
    picker.allowsEditing = false
    picker.delegate = self
    navigationController!.presentViewController(picker, animated: true, completion: nil)
  }
  
  func addPhoto(action: UIAlertAction!) {
    let picker = UIImagePickerController()
    picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    picker.allowsEditing = false
    picker.delegate = self
    navigationController!.presentViewController(picker, animated: true, completion: nil)
  }
  
  func deletePoint(action: UIAlertAction!) {
    let alert = UIAlertController(title: "Delete this point?", message: "Once you delete a point any attachments will also be deleted. This cannot be undone.", preferredStyle: .ActionSheet)
    alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: reallyDelete))
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  func reallyDelete(action: UIAlertAction!) {
    for attachment in attachments {
      attachment.destroy()
    }
    point.destroy()
    self.navigationController!.popViewControllerAnimated(true)
  }
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "showAttachmentSegue" {
      if let vc = segue.destinationViewController as? PQGAttachmentViewController {
        // do stuff
        let cell = sender as PQGCell
        vc.attachment = attachments[self.collectionView.indexPathForCell(cell)!.row]
      }
    } else if segue.identifier == "editTagsSegue" {
      if let vc = segue.destinationViewController as? PQGPointAddTagsTableViewController {
        vc.point = point
      }
    } else if segue.identifier == "pushToTagPointsFromPoint" {
      let cell = sender as PQGCell
      let indexPath = collectionView.indexPathForCell(cell)
      let vc = segue.destinationViewController as PQGPointsViewController
      let tag = tags[indexPath!.row]
      vc.datasourceFetchAll = {
        return tag.points
      }
      vc.datasourceCreatedNewPoint = { point in
        point.addTag(tag)
      }
    } else if segue.identifier == "editMemoSegue" {
      if let vc = segue.destinationViewController as? PQGMemoEditorViewController {
        vc.point = point
      }
    }
  }
  
}
