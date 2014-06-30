//
//  UIImageSizer.h
//  TableTest
//
//  Created by Patrick Quinn-Graham on 09-06-23.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage(Sizer)

- (UIImage*)pqg_scaleAndRotateImage:(int)maxSize;
- (UIImage*)pqg_scaleandRotateImageWithMinimimSideLength:(int)minSize;

@end
