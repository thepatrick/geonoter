//
//  TagsViewController.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 12/01/09.
//  Copyright 2009 Bunkerworld Publishing Ltd.. All rights reserved.
//

#import "TagsViewHome.h"
#import "TagsViewController.h"


@implementation TagsViewController

@synthesize homeView;

- (void)viewDidLoad {
	self.homeView = [[TagsViewHome alloc] initWithNibName:@"TagsViewHome" bundle:nil];
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
