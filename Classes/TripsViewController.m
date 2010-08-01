//
//  FirstViewController.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "TripsViewHome.h"
#import "TripsViewController.h"

@implementation TripsViewController

@synthesize homeView;

- (void)viewDidLoad {
	self.homeView = [[TripsViewHome alloc] initWithNibName:@"TripsViewHome" bundle:nil];
	NSLog(@"homeView arrr: %@", self.homeView);
	[self pushViewController:homeView animated:NO];
	self.navigationBar.tintColor = [UIColor colorWithRed:(39.0/255) green:(28.0/255) blue:(35.0/255) alpha:0];
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
