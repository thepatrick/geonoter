//
//  PointsViewController.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 13/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import "PointsViewHome.h"
#import "PointsViewController.h"


@implementation PointsViewController

@synthesize homeView;

- (void)viewDidLoad {
	self.homeView = [[PointsViewHome alloc] initWithNibName:@"PointsViewHome" bundle:nil];
	NSLog(@"homeView arrr: %@", self.homeView);
	[self pushViewController:homeView animated:NO];
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
	[homeView release];
    [super dealloc];
}


@end
