//
//  MapViewCell.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 14/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import "MapViewCell.h"


@implementation MapViewCell

@synthesize longitude;
@synthesize latitude;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		
		mapView = [[UIWebView alloc] initWithFrame:frame];
		[self addSubview:mapView];
		
    }
    return self;
}

- (void)layoutSubviews {
	NSLog(@"-layoutSubviews!");
	[super layoutSubviews];
	
	CGRect fr = self.contentView.frame;
	fr.origin.x = 0;
	fr.origin.y = 0;
	mapView.frame = fr;
	
	NSString *sampleMap = [[NSBundle mainBundle] pathForResource:@"SampleMap" ofType:@"png"];
	NSURL *url = [NSURL fileURLWithPath:sampleMap];
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	[mapView loadRequest:req];
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
