//
//  PointMemo.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 09-06-20.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersistStore;
@class GNPoint;
@class PointsDetail;

@interface PointMemo : UIViewController {

	IBOutlet UITextView *memoField;
	
	GNPoint *point;
	PersistStore *store;
	PointsDetail *delegate;
	
}

@property (nonatomic, retain) UITextView *memoField;
@property (nonatomic, retain) GNPoint *point;
@property (nonatomic, retain) PersistStore *store;
@property (nonatomic, retain) PointsDetail *delegate;

+pointsMemoWithPoint:(GNPoint*)point andStore:(PersistStore*)store;

-(IBAction)cancel:(id)sender;
-(IBAction)done:(id)sender;

@end
