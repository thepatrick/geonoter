//
//  PointsViewHome.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 13/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class GNPoint;

@protocol MKReverseGeocoderDelegate;


@interface PointsViewHome : UIViewController<UITableViewDelegate, UITableViewDataSource> {

	IBOutlet UITableView *pointsTable;
	IBOutlet UIBarButtonItem *addPoint;
	
	NSArray *points;
	
	NSArray* (^datasourceFetchAll)();
	void (^datasourceDidCreateNewPoint)(GNPoint*);
}


@property (nonatomic, retain) IBOutlet UITableView *pointsTable;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addPoint;
@property (nonatomic, retain) NSArray *points;

-(void)reloadData;
-(IBAction)addPoint:(id)sender;
-(void)showLoading;

-(void)setDatasourceFetchAll:(NSArray* (^)())block;
-(void)setDatasourceDidCreateNewPoint:(void (^)(GNPoint*))block;

@end
