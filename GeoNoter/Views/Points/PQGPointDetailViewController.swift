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
  func sizeOfString (_ string: String, constrainedToWidth width: Double) -> CGSize {
    return NSString(string: string).boundingRect(with: CGSize(width: width, height: DBL_MAX),
      options: NSStringDrawingOptions.usesLineFragmentOrigin,
      attributes: [NSFontAttributeName: self],
      context: nil).size
  }
}

class  PQGLocation : NSObject, MKAnnotation {

  var coordinate : CLLocationCoordinate2D
  var title: String?
  
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
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    self.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    point.hydrate()
    NSLog("point friendlyName \(point.friendlyName)")
    reloadData()
  }
  
  func reloadData() {
    tagCache = nil
    attachmentCache = nil
    collectionView?.reloadData()
  }
  
  //MARK: - Cell methods
  
  func cellForMapRow(_ indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: "mapCell", for: indexPath) as! PQGPointDetailHeader

    NSLog("Header section for CSStickyHeaderParallaxHeader")
    let coordinate = CLLocationCoordinate2D(latitude: point.latitude!, longitude: point.longitude!)
    let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
    cell.mapView!.setRegion(region, animated: false)
    if cell.mapView!.annotations.count == 0 {
        cell.mapView!.addAnnotation(PQGLocation(coordinate: coordinate, title: point.name!))
    }    
    return cell
  }
  
  func cellForDetailsRow(_ indexPath: IndexPath) -> UICollectionViewCell {
    let cellIdentifier = (indexPath as NSIndexPath).row < 2 ? "multilineCell" : "cell"
    let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PQGCell

    cell.textLabel!.text = sectionNames[(indexPath as NSIndexPath).section]
    cell.textLabel!.textColor = UIColor.black()
    
    switch (indexPath as NSIndexPath).row {
    case 0:
      cell.textLabel!.text = point.friendlyName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
    case 1:
      cell.textLabel!.text = point.memo ?? "No memo"
      if cell.textLabel!.text == "No memo" {
        cell.textLabel!.textColor = UIColor.lightGray()
      }
    case 2:
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .mediumStyle
      dateFormatter.timeStyle = .mediumStyle
      if let recordedAt = point.recordedAt {
        cell.textLabel!.text = dateFormatter.string(from: recordedAt as Date)
      } else {
        cell.textLabel!.text = "Missing recordedAt"
      }
    case 3:
      if let lat = point.latitude {
        if let lng = point.longitude {
          cell.textLabel!.text = "\(lat), \(lng)"
        }
      }
    default:
      assert(false, "Unexpected row count in cellForDetailsRow")
    }
    
    return cell
  }
  
  func cellForTagRow(_ indexPath: IndexPath) -> UICollectionViewCell {
    if tags.count == 0 {
      let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: "chooseTagsCell", for: indexPath) as! PQGCell
      cell.textLabel!.text = "Tap to choose tags"
      cell.textLabel!.textColor = UIColor.darkGray()
      return cell
    } else {
      let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! PQGCell
      let tag = tags[(indexPath as NSIndexPath).row].hydrate()
      cell.textLabel!.text = tag.name
      cell.textLabel!.textColor = UIColor.black()
      return cell
    }
  }
  
  func cellForAttachmentsRow(_ indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: "attachmentCell", for: indexPath) as! PQGCell
    
    cell.textLabel!.text = attachments[(indexPath as NSIndexPath).row].hydrate().friendlyName
    cell.textLabel!.textColor = UIColor.black()

    return cell
  }
  
  //MARK: - CollectionView delegate/datasource methods
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return attachments.count > 0 ? 4 : 3
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch (indexPath as NSIndexPath).section {
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
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section < 2 {
      return CGSize(width: 0, height: 0)
    } else {
      return CGSize(width: collectionView.bounds.size.width, height: 50)
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    NSLog("Header section for %@", sectionNames[(indexPath as NSIndexPath).section])
    let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as! PQGCell
    if (indexPath as NSIndexPath).section == 0 {
      cell.textLabel!.text = point.name
    } else {
      cell.textLabel!.text = sectionNames[(indexPath as NSIndexPath).section]
    }
    return cell
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    var w = collectionView.frame.width
    var h : CGFloat = 46.0
    
    if (indexPath as NSIndexPath).section == 0 {
      h = 200
    } else  if collectionView.traitCollection.horizontalSizeClass != .compact {
      w = 320
    }
    
    if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
      if let friendlyName = point.friendlyName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
        let f = UIFont.systemFont(ofSize: 17.0)
        h = f.sizeOfString(friendlyName, constrainedToWidth: Double(w) - 40).height + 25
      }
    }
    
    return CGSize(width: w, height: h)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    NSLog("didSelectItemAtIndexPath %@", indexPath)
  }
  
  //MARK: - MapViewDelegate
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "standardPin") as? MKPinAnnotationView
    
    if pin == nil {
      pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "standardPin")
    } else {
      pin!.annotation = annotation
    }
    pin!.animatesDrop = false

    return pin
  }
  
  //MARK: - UIImagePickerControllerDelegate
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    NSLog("Good news, the image picker went away!")
    picker.dismiss(animated: true, completion: nil)
  }

  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    let data = UIImageJPEGRepresentation(image, 1.0)
    
    let attachment = self.point.addAttachment(data!, withExtension: "jpg")
    
    NSLog("attachment %@", attachment)
    
    picker.dismiss(animated: true, completion: nil)
    reloadData()
  }
  
  //MARK: - Action Button
  
  @IBAction func actionButtonPressed(_ sender: UIBarButtonItem) {
    let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    sheet.addAction(UIAlertAction(title: "Delete Point", style: UIAlertActionStyle.destructive, handler: deletePoint))
    sheet.addAction(UIAlertAction(title: "Manage Tags", style: UIAlertActionStyle.default, handler: manageTags))
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      sheet.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default, handler: takePhoto))
    }
    
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      sheet.addAction(UIAlertAction(title: "Add Existing Photo", style: UIAlertActionStyle.default, handler: addPhoto))
    }
    
    sheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
    self.present(sheet, animated: true, completion: nil)
  }
  
  func manageTags(_ action: UIAlertAction!) {
    performSegue(withIdentifier: "editTagsSegue", sender: self)
  }
  
  func takePhoto(_ action: UIAlertAction!) {
    let picker = UIImagePickerController()
    picker.sourceType = .camera
    picker.allowsEditing = false
    picker.delegate = self
    navigationController!.present(picker, animated: true, completion: nil)
  }
  
  func addPhoto(_ action: UIAlertAction!) {
    let picker = UIImagePickerController()
    picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
    picker.allowsEditing = false
    picker.delegate = self
    navigationController!.present(picker, animated: true, completion: nil)
  }
  
  func deletePoint(_ action: UIAlertAction!) {
    let alert = UIAlertController(title: "Delete this point?", message: "Once you delete a point any attachments will also be deleted. This cannot be undone.", preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: reallyDelete))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  func reallyDelete(_ action: UIAlertAction!) {
    for attachment in attachments {
      attachment.destroy()
    }
    point.destroy()
    self.navigationController!.popViewController(animated: true)
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "showAttachmentSegue" {
      if let vc = segue.destinationViewController as? PQGAttachmentViewController {
        // do stuff
        let cell = sender as! PQGCell
        vc.attachment = attachments[(self.collectionView!.indexPath(for: cell)! as NSIndexPath).row]
      }
    } else if segue.identifier == "editTagsSegue" {
      if let vc = segue.destinationViewController as? PQGPointAddTagsTableViewController {
        vc.point = point
      }
    } else if segue.identifier == "pushToTagPointsFromPoint" {
      let cell = sender as! PQGCell
      let indexPath = collectionView!.indexPath(for: cell)
      let vc = segue.destinationViewController as! PQGPointsViewController
      let tag = tags[(indexPath! as NSIndexPath).row]
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
