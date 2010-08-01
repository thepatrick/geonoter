//
//  SettingsAbout.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 10-08-01.
//  Copyright (c) 2010 Sharkey Media. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsAbout : UIViewController {
 
    UIWebView *webView;
    NSString *pageToLoad;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, copy) NSString *pageToLoad;

+aboutWithPage:(NSString*)pathToPage;

@end
