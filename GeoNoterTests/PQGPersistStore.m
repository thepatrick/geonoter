//
//  PQGPersistStore.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 11/07/2014.
//  Copyright (c) 2014 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "PersistStore.h"

@interface PQGPersistStore : XCTestCase

@end

@implementation PQGPersistStore

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAttachmentsDirectory
{
  NSString *attach = [PersistStore attachmentsDirectory];
  XCTAssertNotNil(attach, @"attachmentsDirectory must not be nil");
  XCTAssertTrue(attach.length > 0, @"attachmentsDirectory must be non-zero length");
}

- (void)testPathForResource
{
  NSString *path = [PersistStore pathForResource:@"bob"];
  XCTAssertNotNil(path);
  XCTAssertTrue([path rangeOfString:@"bob"].length > 0, @"pathForResource does not contain resource name");
}

- (void)testPathForCashResource
{
  NSURL *url = [PersistStore pathForCacheResource:@"bob"];
  XCTAssertNotNil(url);
  XCTAssertTrue([url.path rangeOfString:@"bob"].length > 0, @"pathForResource does not contain resource name");
}

- (void)testAttachmentsCacheDirectory
{
  NSURL *url = [PersistStore attachmentsCacheDirectory];
  XCTAssertNotNil(url);
  XCTAssertTrue([url.path rangeOfString:@"Attachments"].length > 0, @"attachmentsCacheDirectory does not contain Attachments");
}

- (void)testAttachmentCacheURL
{
  NSURL *attachmentsCacheDirectory = [PersistStore attachmentsCacheDirectory];
  NSURL *url = [PersistStore attachmentCacheURL:@"bob.jpg"];
  XCTAssertNotNil(url);
  XCTAssertTrue([url.path rangeOfString:attachmentsCacheDirectory.path].length > 0, @"attachmentCacheURL does not contain attachmentsCacheDirectory");
  XCTAssertTrue([url.path rangeOfString:@"bob.jpg"].length > 0, @"attachmentCacheURL does not contain attachment name");
}

- (void)testUnopenedStore
{
  NSString *testFile = [PersistStore pathForResource:@"test.db"];
  if([[NSFileManager defaultManager] fileExistsAtPath:testFile]) {
    NSError *err;
    if(![[NSFileManager defaultManager] removeItemAtPath:testFile error:&err]) {
      XCTFail(@"Unable to remove test.db %@", err.localizedDescription);
    }
  }
  PersistStore *store = [[PersistStore alloc] init];
  XCTAssertNil(store.db, @"PersistStore has database before being told to open one.");

  [store openDatabase:testFile];

  XCTAssertNotNil(store.db, @"PersistStore has no database after openDatabase is called");

  [store closeDatabase];
  
  XCTAssertNil(store.db, @"PersistStore has database before being told to close it");
  
}

- (void)testOpenAndCloseStoreTimeWithMigrations
{
  NSString *testFile = [PersistStore pathForResource:@"test.db"];
  NSFileManager *fm = [NSFileManager defaultManager];
  [self measureBlock:^{
    if([fm fileExistsAtPath:testFile]) {
      NSError *err;
      if(![fm removeItemAtPath:testFile error:&err]) {
        XCTFail(@"Unable to remove test.db %@", err.localizedDescription);
      }
    }
    PersistStore *store = [[PersistStore alloc] init];
    [store openDatabase:testFile];
    [store closeDatabase];
  }];
}

- (void)testOpenAndCloseStoreTimeWithoutMigrations
{
  NSString *testFile = [PersistStore pathForResource:@"test.db"];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  if([fm fileExistsAtPath:testFile]) {
    NSError *err;
    if(![fm removeItemAtPath:testFile error:&err]) {
      XCTFail(@"Unable to remove test.db %@", err.localizedDescription);
    }
  }

  PersistStore *store = [[PersistStore alloc] init];
  [store openDatabase:testFile];
  [store closeDatabase];

  [self measureBlock:^{
    PersistStore *store = [[PersistStore alloc] init];
    [store openDatabase:testFile];
    [store closeDatabase];
  }];
  
}

@end
