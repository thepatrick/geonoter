//
//  PointAttachmentImage.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 09-06-21.
//  Copyright 2009 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"

@class TTImageView;
@class GNAttachment;

@interface PointAttachmentImage : UIViewController<TTImageViewDelegate, UIScrollViewDelegate> {
	
	IBOutlet UIScrollView *scrollView; 
	TTImageView *imageView;
	
	GNAttachment *attachment;
	
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) TTImageView *imageView;
@property (nonatomic, retain) GNAttachment *attachment;

+attachmentImageWithAttachment:(GNAttachment*)attach;

@end
