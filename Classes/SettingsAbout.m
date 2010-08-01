//
//  SettingsAbout.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 10-08-01.
//  Copyright (c) 2010 Sharkey Media. All rights reserved.
//

#import "SettingsAbout.h"


@implementation SettingsAbout

@synthesize webView, pageToLoad;

+aboutWithPage:(NSString*)pathToPage {
    SettingsAbout *sb = [[[SettingsAbout alloc] initWithNibName:@"SettingsAbout" bundle:nil] autorelease];
    sb.pageToLoad = pathToPage;
	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"]];
	[sb.webView loadRequest:[NSURLRequest requestWithURL:url]];
    return sb;
}

-(void)viewWillAppear:(BOOL)animated {
	NSURL *url = [NSURL fileURLWithPath:self.pageToLoad];
	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
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
    [pageToLoad release];
    [super dealloc];
}


@end
