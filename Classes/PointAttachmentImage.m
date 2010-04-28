//
//  PointAttachmentImage.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 09-06-21.
//  Copyright 2009 Patrick Quinn-Graham. All rights reserved.
//

#import "PointAttachmentImage.h"
#import "GNAttachment.h"
#import "GeoNoterAppDelegate.h"

@implementation PointAttachmentImage

@synthesize scrollView, imageView, attachment;

+attachmentImageWithAttachment:(GNAttachment*)attach {
	PointAttachmentImage *pai = [[[self alloc] initWithNibName:@"PointAttachmentImage" bundle:nil] autorelease];
	pai.attachment = attach;
	return pai;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	imageView = [[TTImageView alloc] initWithFrame:scrollView.frame];
	imageView.autoresizesToImage = YES;
	imageView.delegate = self;
	[scrollView addSubview:imageView];
}

- (void)viewWillAppear:(BOOL)animated {
	[attachment hydrate];
	self.title = attachment.friendlyName;

	NSString *base = [(GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate] attachmentsDirectory];
	
	
	imageView.urlPath = [@"file://" stringByAppendingString:[base stringByAppendingPathComponent:attachment.fileName]];
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
#pragma mark TTImageViewDelegate

- (void)imageView:(TTImageView*)iv didLoadImage:(UIImage*)image {

	NSLog(@"imageView:didLoadImage: %@", image);
	
	scrollView.contentSize = iv.frame.size;
	
}

- (void)imageViewDidStartLoad:(TTImageView*)imageView {
	NSLog(@"imageViewDidStartLoad");	
}

- (void)imageView:(TTImageView*)imageView didFailLoadWithError:(NSError*)error {
	NSLog(@"imageView:didFailLoadWithError: %@", error);	
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)sv {
	return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	NSLog(@"didEndZooming");
}

@end
