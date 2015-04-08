//
//  WebRtcSocketTest.m
//  IM
//
//  Created by 郭志伟 on 15-3-25.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "WebRtcWebSocketChannel.h"

@interface WebRtcSocketTest : XCTestCase <WebRtcWebSocketChannelDelegate>

@end

@implementation WebRtcSocketTest

- (void)setUp {
    [super setUp];
    NSURL *url = [NSURL URLWithString:@"ws://10.22.1.153:8088/webrtc"];
    WebRtcWebSocketChannel *channel = [[WebRtcWebSocketChannel alloc] initWithUrl:url delegate:self];
    [channel connect];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)channel:(WebRtcWebSocketChannel *)channel
 didChangeState:(WebRtcWebSocketChannelState)state {
    NSLog(@"%d", state);
}

- (void)channel:(WebRtcWebSocketChannel *)channel
didReceiveMessage:(WebRtcSignalingMessage *)message {
    
}

@end
