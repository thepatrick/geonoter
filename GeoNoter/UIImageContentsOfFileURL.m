//
//  UIImageContentsOfFileURL.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 29/06/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

#import "UIImageContentsOfFileURL.h"

@implementation  UIImage(ContentsOfFileURL)

- (instancetype)initWithContentsOfFileURL:(NSURL *)path {
  return [self initWithContentsOfFile:path.path];
}

@end
