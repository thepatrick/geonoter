//
//  MapViewCell.m
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 14/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "MapViewCell.h"


@implementation MapViewCell

@synthesize longitude;
@synthesize latitude;
@synthesize coordinate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		mapView = [[MKMapView alloc] initWithFrame:self.frame];
		mapView.delegate = self;
		[self addSubview:mapView];
		
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect fr = self.contentView.frame;
	fr.origin.x = 0;
	fr.origin.y = 0;
	mapView.frame = fr;
	
	coordinate.latitude = self.latitude;
	coordinate.longitude = self.longitude;
	
	
	MKCoordinateRegion 	region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
	//region = [mapView regionThatFits:region];
	[mapView setRegion:region animated:NO];
	
	[mapView addAnnotation:self];
	
	
}

- (MKAnnotationView *)mapView:(MKMapView *)thisMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *pin =  (MKPinAnnotationView*)[thisMapView dequeueReusableAnnotationViewWithIdentifier:@"standardPin"];
	if(!pin) {
		pin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"standardPin"] autorelease];
	}
	pin.annotation = annotation;
	pin.animatesDrop = NO;
	return pin;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[mapView release];
    [super dealloc];
}

-(NSString*)title {
	return @"no title!";
}

@end
