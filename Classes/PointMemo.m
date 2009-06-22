//
//  PointMemo.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 09-06-20.
//  Copyright 2009 Patrick Quinn-Graham. All rights reserved.
//

#import "PointMemo.h"
#import "GNPoint.h"
#import "PersistStore.h"
#import "PointsDetail.h"


@implementation PointMemo

@synthesize memoField, point, store, delegate;

+pointsMemoWithPoint:(GNPoint*)point andStore:(PersistStore*)store {
	PointMemo *newMemo = [[[self alloc] initWithNibName:@"PointMemo" bundle:nil] autorelease];
	if(newMemo) {
		newMemo.point = point;
		newMemo.store = store;
	}
	return newMemo;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
	[point dehydrate];
}

- (void)dealloc {
	[delegate release];
	[point release];
	[store release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[point hydrate];
	memoField.text = point.memo;
	[memoField becomeFirstResponder];
}

#pragma mark -
#pragma mark View Actions
-(IBAction)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}
-(IBAction)done:(id)sender {
	[point hydrate];
	point.memo = memoField.text;
	NSLog(@"Putting the memo in the mailbox.. %@", point.memo);
	[point save];
	[delegate reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

@end
