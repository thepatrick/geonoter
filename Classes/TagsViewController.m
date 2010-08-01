//
//  TagsViewController.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 12/01/09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "TagsViewHome.h"
#import "TagsViewController.h"


@implementation TagsViewController

@synthesize homeView;

- (void)viewDidLoad {
	self.homeView = [[TagsViewHome alloc] initWithNibName:@"TagsViewHome" bundle:nil];
	NSLog(@"homeView arrr: %@", self.homeView);
	[self pushViewController:homeView animated:NO];
	self.navigationBar.tintColor = [UIColor colorWithRed:(29.0/255) green:(39.0/255) blue:(17.0/255) alpha:0];
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
