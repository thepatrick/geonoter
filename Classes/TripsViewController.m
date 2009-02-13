//
//  FirstViewController.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/01/09.
//  Copyright Bunkerworld Publishing Ltd. 2009. All rights reserved.
//

#import "TripsViewHome.h"
#import "TripsViewController.h"

@implementation TripsViewController

@synthesize homeView;

- (void)viewDidLoad {
	self.homeView = [[TripsViewHome alloc] initWithNibName:@"TripsViewHome" bundle:nil];
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
