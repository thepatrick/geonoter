//
//  MapViewCell.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 14/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapViewCell : UITableViewCell<MKMapViewDelegate, MKAnnotation> {
	
	MKMapView *mapView;
	
	CGFloat longitude;
	CGFloat latitude; 
	
	CLLocationCoordinate2D coordinate;
	
}

@property (nonatomic, assign) CGFloat longitude; 
@property (nonatomic, assign) CGFloat latitude; 
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
