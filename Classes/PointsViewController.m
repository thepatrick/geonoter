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
	self.navigationBar.tintColor = [UIColor colorWithRed:(18.0/255) green:(32.0/255) blue:(39.0/255) alpha:0];
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
