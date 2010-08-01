//
//  PointAttachmentImage.m
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 09-06-21.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "PointAttachmentImage.h"
#import "GNAttachment.h"
#import "GeoNoterAppDelegate.h"
#import "UIImageSizer.h"
#import "TextAlertView.h"

@implementation PointAttachmentImage

@synthesize scrollView, imageView, attachment, actionButton;

+attachmentImageWithAttachment:(GNAttachment*)attach {
	PointAttachmentImage *pai = [[[self alloc] initWithNibName:@"PointAttachmentImage" bundle:nil] autorelease];
	pai.attachment = attach;
	return pai;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.actionButton;
}

- (void)viewWillAppear:(BOOL)animated {
	[attachment hydrate];
	self.title = attachment.friendlyName;
	imageView = [[[UIImageView alloc] initWithFrame:scrollView.frame] autorelease];
	imageView.hidden = YES;
	[scrollView addSubview:imageView];
	scrollView.zoomScale = 1.0;
}

- (void)viewDidAppear:(BOOL)animated {
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.delegate = self;
	[HUD showWhileExecuting:@selector(loadImage) onTarget:self withObject:nil animated:YES];
}

- (void)loadImage {
	DLog(@"Loading image for attachment %@", attachment);
	NSString *full = [attachment filesystemPath];
	NSString *cachedPath = [[attachment filesystemPath] stringByAppendingFormat:@".cached.%@", [attachment.fileName pathExtension]];
	UIImage *img2;
	if([[NSFileManager defaultManager] fileExistsAtPath:cachedPath]) {
		img2 = [UIImage imageWithContentsOfFile:cachedPath];
		DLog(@"Loaded %@ from cache %@", full, cachedPath);
	} else {
		UIImage *img = [UIImage imageWithContentsOfFile:full];
		DLog(@"img: %f x %f", img.size.width, img.size.height);
		img2 = [img scaleAndRotateImage:1024];
		DLog(@"img: %f x %f", img2.size.width, img2.size.height);
		
		NSData *d = UIImageJPEGRepresentation(img2, 1.0);
		[d writeToFile:cachedPath atomically:YES];
		DLog(@"Wrote %@ to cache %@", full, cachedPath);
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		CGRect frame = imageView.frame;
		frame.size = img2.size;
		imageView.frame = frame;
		
		imageView.image = img2;	
		
		CGRect scrollFrame = scrollView.frame;
		
		[scrollView setContentSize: CGSizeMake(imageView.bounds.size.width, imageView.bounds.size.height)];
		
		scrollView.clipsToBounds = YES;
		[scrollView zoomToRect:imageView.frame animated:NO];
		frame = imageView.frame;
		CGPoint contentOffset = CGPointMake((frame.size.width-scrollFrame.size.width)/2,
											(frame.size.height-scrollFrame.size.height)/2);
		scrollView.contentOffset = contentOffset;

		
		scrollView.minimumZoomScale = scrollView.zoomScale;
		imageView.hidden = NO;
	});
}

- (void)viewDidDisappear:(BOOL)animated {
	imageView.image = nil;
	[imageView removeFromSuperview];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	[attachment dehydrate];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[attachment release];
	[super dealloc];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)sv {
	return imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)pScrollView {
	CGRect innerFrame = imageView.frame;
	CGRect scrollerBounds = pScrollView.bounds;
	if ((innerFrame.size.width < scrollerBounds.size.width) || (innerFrame.size.height < scrollerBounds.size.height)) {
		CGFloat tempx = imageView.center.x - ( scrollerBounds.size.width / 2 );
		CGFloat tempy = imageView.center.y - ( scrollerBounds.size.height / 2 );
		CGPoint myScrollViewOffset = CGPointMake( tempx, tempy);
		pScrollView.contentOffset = myScrollViewOffset;
	}
	UIEdgeInsets anEdgeInset = { 0, 0, 0, 0 };
	if (scrollerBounds.size.width > innerFrame.size.width) {
		anEdgeInset.left = (scrollerBounds.size.width - innerFrame.size.width) / 2;
		anEdgeInset.right = -anEdgeInset.left;  // I don't know why this needs to be negative, but that's what works
	}
	if (scrollerBounds.size.height > innerFrame.size.height) {
		anEdgeInset.top = (scrollerBounds.size.height - innerFrame.size.height) / 2;
		anEdgeInset.bottom = -anEdgeInset.top;  // I don't know why this needs to be negative, but that's what works
	}
	pScrollView.contentInset = anEdgeInset;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
}

#pragma mark -
#pragma mark Actions

- (IBAction)actionButtonAction:(id)sender {
	
	pointActions = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" 
									 destructiveButtonTitle:@"Delete Photo" otherButtonTitles:@"Email Photo", @"Save to Camera Roll", @"Rename Photo", nil];

	
	[pointActions showInView:self.navigationController.tabBarController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(actionSheet == pointActions) {
		switch(buttonIndex) {
				
			case 0: // 0 = delete
				[self actionSheetDeleteMe];
				break;
			case 1: // 1 = email photo
				[self actionSheetSendEmail];
				break;
			case 2: // 2 = Save to camera roll
				[self actionSheetSaveToRoll];
				break;
			case 3: // 3 = Rename photo
				[self actionSheetRenameMe];
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
	[attachment deleteAttachment];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)actionSheetSendEmail {
	if(![MFMailComposeViewController canSendMail]) {
		[(GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate] launchMailAppOnDevice];
		return;
	}
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
	[picker setSubject:attachment.friendlyName];
	NSData *myData = [NSData dataWithContentsOfFile:[attachment filesystemPath]];
	[picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:attachment.fileName];
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

-(void)actionSheetSaveToRoll {
	ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
	UIImage *image = [UIImage imageWithContentsOfFile:[attachment filesystemPath]];
    
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error){
		if(error != nil) {
			[[[UIAlertView alloc] initWithTitle:@"Your photo could not be saved to the photo roll." message:[error description] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
		} else {
			DLog(@"Photo saved to %@", assetURL);
		}
	}];
	[library release];
}

-(void)actionSheetRenameMe {
	TextAlertView *alert = [[TextAlertView alloc] initWithTitle:@"Rename Photo" 
														message:nil 
													   delegate:self cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Rename", nil];
	alert.textField.keyboardType = UIKeyboardTypeDefault;
	alert.textField.text = self.attachment.friendlyName;
	[alert show];
	[alert release];
}

-(void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	TextAlertView *alertView = (TextAlertView*) actionSheet;
	if(buttonIndex > 0) {
		NSString *textValue = alertView.textField.text;
		if(textValue==nil)
			return;
		// do something meaningful with textValue
		[attachment hydrate];
		attachment.friendlyName = textValue;
		self.title = attachment.friendlyName;
		[attachment save];
	}
}

#pragma mark -
#pragma mark Email stuff

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error  {   
	[self dismissModalViewControllerAnimated:YES];
}
@end
