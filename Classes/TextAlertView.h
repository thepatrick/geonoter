//
//  TextAlertView.h
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 10-05-15.
//  Copyright 2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kUITextFieldHeight 30.0
#define kUITextFieldXPadding 12.0
#define kUITextFieldYPadding 10.0
#define kUIAlertOffset 0.0

@interface TextAlertView : UIAlertView {
	UITextField *textField;
	BOOL layoutDone;
}

@property (nonatomic, retain) UITextField *textField;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end