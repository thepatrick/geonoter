//
//  UIImageSizer.h
//  TableTest
//
//  Created by Patrick Quinn-Graham on 09-06-23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage(Sizer)

- (UIImage*)scaleAndRotateImage:(int)maxSize;
- (UIImage*)scaleandRotateImageWithMinimimSideLength:(int)minSize;

@end
