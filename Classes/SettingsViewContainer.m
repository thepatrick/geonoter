    //
//  SettingsViewContainer.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 10-05-22.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import "SettingsViewContainer.h"
#import "Settings.h"


@implementation SettingsViewContainer

@synthesize settingsView;

- (void)viewDidLoad {
	self.settingsView = [[Settings alloc] initWithNibName:@"SettingsView" bundle:nil];
	[self pushViewController:settingsView animated:NO];
	//self.navigationBar.barStyle = UIStatusBarStyleBlackOpaque;
	[super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
