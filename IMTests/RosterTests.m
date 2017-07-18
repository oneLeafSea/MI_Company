//
//  RosterTests.m
//  IM
//
//  Created by 郭志伟 on 14-12-26.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
//#import "RosterDb.h"
#import "NSUUID+StringUUID.h"

@interface RosterTests : XCTestCase {
//    Roster *r;
//    RosterDb *rd;
}

@end

@implementation RosterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
//    r = [[Roster alloc] init];
//    rd = [[RosterDb alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
//    r.uid = [NSUUID uuid];
//    r.items = @"items";
//    r.grp = @"grp";
//    r.desc = @"desc";
//    r.ver = @"0.1";
//    
//    if (![rd insertRoster:r]) {
//        XCTAssert(NO, @"ERROR: insertRoster");
//    }
//    
//    
//    r.grp = [NSString stringWithFormat:@"%@'s grp", r.uid];
//    if (![rd updateRoster:r]) {
//        XCTAssert(NO, @"ERROR: update");
//    }
//    
//    r = [rd getRosterByUid:r.uid];
//    
//    NSLog(@"%@, %@", r.uid, r.grp);
//    
//    NSArray *arr = [rd getAllRosters];
//    if (arr.count == 0) {
//        XCTAssert(NO, @"ERROR: getAllRosters");
//    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
//        r.uid = [NSUUID uuid];
//        r.items = @"items";
//        r.grp = @"grp";
//        r.desc = @"desc";
//        r.ver = @"0.1";
//        if (![rd insertRoster:r]) {
//            XCTAssert(NO, @"ERROR: insert");
//        }
    }];
}

@end
