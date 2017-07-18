//
//  MessageQueueNode.m
//  WH
//
//  Created by guozw on 14-10-13.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "MessageQueueNode.h"

#import "LogLevel.h"
#import "ObjCMongoDB.h"
#import "DataConstants.h"

@implementation MessageQueueNode



- (instancetype)initWithMessage:(Request *)msg timeout:(NSUInteger)sec {
    if (self = [super init]) {
        _msg = msg;
        _timeout = sec;
        _stick = 0;
        _hb = NO;
    }
    return self;
}

#if DEBUG
- (void)dealloc {
    DDLogVerbose(@"%@ dealloc", NSStringFromClass([self class]));
}
#endif


- (BOOL)isTimeout {
    if (self.timeout <= _stick) {
        return YES;
    }
    return NO;
}

@end