//
//  PointAttachmentImage.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 09-06-21.
//  Copyright 2009 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MBProgressHUD.h"

@class GNAttachment;

@interface PointAttachmentImage : UIViewController<UIScrollViewDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	
	IBOutlet UIScrollView *scrollView; 
	UIImageView *imageView;
	IBOutlet UIBarButtonItem *actionButton;
	UIActionSheet *pointActions;
	MBProgressHUD *HUD;

	GNAttachment *attachment;
	BOOL firstLoad;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) GNAttachment *attachment;

+attachmentImageWithAttachment:(GNAttachment*)attach;

- (IBAction)actionButtonAction:(id)sender;

-(void)actionSheetDeleteMe;
-(void)actionSheetSendEmail;
-(void)actionSheetSaveToRoll;
-(void)actionSheetRenameMe;

@end
