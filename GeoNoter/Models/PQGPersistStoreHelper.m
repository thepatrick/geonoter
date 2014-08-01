//
//  PQGPersistStoreHelper.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 1/08/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

#import "PQGPersistStoreHelper.h"

@implementation PQGPersistStoreHelper

+ (int64_t)primaryKeyForNewInstance
{
  // Otherwise, issue random 64-bit signed ints
  uint64_t urandom;
  if (0 != SecRandomCopyBytes(kSecRandomDefault, sizeof(uint64_t), (uint8_t *) (&urandom))) {
    arc4random_stir();
    urandom = ( ((uint64_t) arc4random()) << 32) | (uint64_t) arc4random();
  }
  
  return (int64_t) (urandom & 0x7FFFFFFFFFFFFFFF);
}

@end
