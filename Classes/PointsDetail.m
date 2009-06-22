//
//  PointsDetail.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 14/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import "MapViewCell.h"
#import "PersistStore.h"
#import "GNPoint.h"
#import "Tag.h"
#import "PointsDetail.h"
#import "GeoNoterAppDelegate.h"
#import "PointsAddTags.h"
#import "PointMemo.h"
#import "GeoNoterAppDelegate.h"
#import "NSStringUUID.h"
#import "GNAttachment.h"
#import "PointAttachmentImage.h"

#define PointsDetailSectionMap 0
#define PointsDetailSectionDetails 1
#define PointsDetailSectionTags 2
#define PointsDetailSectionAttachments 3

@implementation PointsDetail

@synthesize locationName;
@synthesize detailTable;
@synthesize point;
@synthesize store;
@synthesize actionButton;

+pointsDetailWithPoint:(GNPoint*)newPoint andStore:(PersistStore*)newStore
{
	PointsDetail *newDetail = [[[self alloc] initWithNibName:@"PointsDetailView" bundle:nil] autorelease];
	newDetail.store = newStore;
	newDetail.point = newPoint;
	return newDetail;
}

- (void)viewDidLoad {
	self.title = @"Location";
	
	self.navigationItem.rightBarButtonItem = self.actionButton;
	sectionNames = [[NSArray arrayWithObjects:@"Map", @"Details", @"Tags", @"Attachments", nil] retain];
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void)viewWillAppear:(BOOL)animated
{
	//[self reloadData];
	NSLog(@"points: %@", point);
	[point hydrate];
	self.locationName.text = point.name;
}

- (void)dealloc {
	[point release];
	[store release];
	[detailTable release];
	[locationName release];
	[sectionNames release];
	[pointActions release];
	[tagCache release];
    [super dealloc];
}

-(void)reloadData {
	[tagCache release];
	tagCache = nil;
	[attachmentCache release];
	attachmentCache = nil;
	
	[detailTable reloadData];
}

#pragma mark -
#pragma mark TableView delegate/datasource methods

-(UITableViewCell*)tableView:(UITableView*)tv cellForMapRow:(NSInteger)row {
	MapViewCell *movieCell = (MapViewCell *)[tv dequeueReusableCellWithIdentifier:@"map"];
	if(!movieCell) {
		movieCell = [[[MapViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"map"] autorelease];
	}
	movieCell.longitude = point.longitude;
	movieCell.latitude = point.latitude;
	return movieCell;
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForDetailsRow:(NSInteger)row {
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"detailsRow"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailsRow"] autorelease];
	}
	
	cell.textLabel.textColor = [UIColor blackColor];

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	NSDateFormatter *dateFormatter;
	switch (row) {
		case 0:
			cell.textLabel.text = point.friendlyName;
			break;
		case 1:
			cell.textLabel.text = point.memo;
			if([point.memo isEqualToString:@"No memo"]) {
				cell.textLabel.textColor = [UIColor lightGrayColor];				
			}
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			break;
		case 2:
			dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
			[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
			cell.textLabel.text = [dateFormatter stringFromDate:point.recordedAt];
			break;
		case 3:
			cell.textLabel.text = [NSString stringWithFormat:@"%f, %f", point.longitude, point.latitude];
	}
	
	//cell.text = point.name;
	
	return cell;
	
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForTagsRow:(NSInteger)row {
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"detailsRow"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"detailsRow"] autorelease];
	}
	
	if(tagCache == nil) {
		tagCache = [[point tags] retain];
	}
	Tag *tag = [[tagCache objectAtIndex:row] hydrate];
	cell.textLabel.text = tag.name;
	
	return cell;
	
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForAttachmentsRow:(NSInteger)row {
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"detailsRow"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"detailsRow"] autorelease];
	}
	
	if(attachmentCache == nil) {
		attachmentCache = [[point attachments] retain];
	}
	GNAttachment *attachment = [[attachmentCache objectAtIndex:row] hydrate];
	cell.textLabel.text = attachment.friendlyName;
	
	return cell;
	
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell *cell;
	
	switch (indexPath.section) {
		case PointsDetailSectionMap: 
			return [self tableView:tv cellForMapRow:indexPath.row];
		
		case PointsDetailSectionDetails: // details
			return [self tableView:tv cellForDetailsRow:indexPath.row];
			
		case PointsDetailSectionTags: // tags
			return [self tableView:tv cellForTagsRow:indexPath.row];
			
		case PointsDetailSectionAttachments: // attachments
			return [self tableView:tv cellForAttachmentsRow:indexPath.row];
			
		default:
			
			cell = [tv dequeueReusableCellWithIdentifier:@"point"];
			if(!cell) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"point"] autorelease];
			}
			
			cell.textLabel.text = point.name;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			return cell;
			
			break;
	}
	return nil;
}

-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case PointsDetailSectionMap: 
			return 1;
			
		case PointsDetailSectionDetails: // details
			return 4;
			
		case PointsDetailSectionTags: // tags
			if(tagCache == nil) {
				tagCache = [[point tags] retain];
			}
			return [tagCache count];
			
		case PointsDetailSectionAttachments: // attachments
			if(attachmentCache == nil) {
				attachmentCache = [[point attachments] retain];
			}
			return [attachmentCache count];
	}
	return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4; // assumes includes recordings
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [sectionNames objectAtIndex:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 0)
		return 200.0;
	else
		return 46.0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	switch (indexPath.section) {
		case PointsDetailSectionMap: 
			return nil;
			
		case PointsDetailSectionDetails: // details
			if(indexPath.row == 1) {
				PointMemo *memo = [PointMemo pointsMemoWithPoint:point andStore:store];
				memo.delegate = self;
				[self presentModalViewController:memo animated:YES];
			}
			return nil;
			
		case PointsDetailSectionTags: // tags
			return indexPath;
			
		case PointsDetailSectionAttachments: // attachments
			[self displayAttachment:indexPath.row];
			return nil;
	}
	return nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if(textField == locationName) {
		point.name = textField.text;
		[point save];
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField == locationName) {
		[textField resignFirstResponder];
	}
	return YES;
}

#pragma mark -
#pragma mark Actions

- (IBAction)actionButtonAction:(id)sender {
	
	// do we have a camera?
	
	BOOL cameras = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	BOOL photoLibrarys = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] || 
						 [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
	
	
	if(!cameras && !photoLibrarys) {
		pointActions = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" 
									 destructiveButtonTitle:@"Delete Point" otherButtonTitles:@"Manage Tags", @"Record Sound", nil];
	} else if(!cameras) { // no camera, but we do have a photo library
		pointActions = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" 
									 destructiveButtonTitle:@"Delete Point" otherButtonTitles:@"Manage Tags", @"Record Sound", @"Add Existing Photo", nil];
	} else if(!photoLibrarys) { // no photo library, but (as we've got this far!) we do have a camera
		pointActions = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" 
									 destructiveButtonTitle:@"Delete Point" otherButtonTitles:@"Manage Tags", @"Record Sound", @"Take Photo", nil];
	} else { // We have both a camera and a photo library to pick from
		pointActions = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" 
									 destructiveButtonTitle:@"Delete Point" otherButtonTitles:@"Manage Tags", @"Record Sound", @"Take Photo", @"Add Existing Photo", nil];
	}
	
	
	[pointActions showInView:self.navigationController.tabBarController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(actionSheet = pointActions) {
		switch(buttonIndex) {
				
			case 0: // 0 = delete
				[self actionSheetDeleteMe];
				break;
				
			case 1: // 1 = add tag
				[self actionSheetAddTags];
				break;
				
			case 3: // 3 = take photo
				[self actionSheetTakePhoto];
				break;
			
			case 4: // 4 = pick photo
				[self actionSheetPickPhoto];
				break;
				
			default:
				break;
				
		}
		
		// 1 = add tag
		// 2 = add sound
		// 3 = take photo
		// 4 = existing
		// else... cancel
		
	}
}

-(void)actionSheetDeleteMe {
	[store deletePointFromStore:[point.dbId integerValue]];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)actionSheetAddTags {
	PointsAddTags *pat = [PointsAddTags pointsAddTagsWithPoint:point andStore:store];
	pat.delegate = self;
	[self presentModalViewController:pat animated:YES];
}

-(void)actionSheetTakePhoto {
	UIImagePickerController *pc = [[UIImagePickerController alloc] init];
	pc.sourceType = UIImagePickerControllerSourceTypeCamera;
	pc.allowsImageEditing = NO;
	pc.delegate = self;
	
	[self.navigationController presentModalViewController:pc animated:YES];
}

-(void)actionSheetPickPhoto {
	UIImagePickerController *pc = [[UIImagePickerController alloc] init];
	pc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	pc.allowsImageEditing = NO;
	pc.delegate = self;
	
	[self.navigationController presentModalViewController:pc animated:YES];	
}

#pragma mark -
#pragma mark UIImagePickerController delegate methods

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self.navigationController dismissModalViewControllerAnimated:YES];
	
	UIImage *editedImage = [info objectForKey:UIImagePickerControllerOriginalImage];

	GeoNoterAppDelegate *ad = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	NSString *base = [ad attachmentsDirectory];
	NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [NSString stringWithUUID]];
		
	NSData *data = UIImageJPEGRepresentation(editedImage, 1.0);
	
	NSString *actualFile = [base stringByAppendingPathComponent:fileName];

	[data writeToFile:actualFile atomically:YES];
	
	GNAttachment *newAttachment = [GNAttachment attachment];
	newAttachment.store = store;
	newAttachment.fileName = fileName;
	newAttachment.kind = @"jpg";
	newAttachment.pointId = [point.dbId integerValue];
	newAttachment.friendlyName = @"New picture";
	newAttachment.memo = @"No memo";
	newAttachment.recordedAt = [NSDate date];
	[newAttachment save];
	
	[self reloadData];
	
	NSLog(@"didFinishPickingMediaWithInfo: %@ \nto %@", info, actualFile);
}

#pragma mark -
#pragma mark Display attachments

-(void)displayAttachment:(NSInteger)index {
	if(attachmentCache == nil) {
		attachmentCache = [[point attachments] retain];
	}
	GNAttachment *attachment = [[attachmentCache objectAtIndex:index] hydrate];
	PointAttachmentImage *pai = [PointAttachmentImage attachmentImageWithAttachment:attachment];
	[self.navigationController pushViewController:pai animated:YES];
}

@end
