//
//  ServerTimeMsg.m
//  WH
//
//  Created by guozw on 14-10-16.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "ServerTimeMsg.h"
#import "MessageConstants.h"

@implementation ServerTimeMsg

- (instancetype)initWithTime:(NSString *)time {
    if (self = [super init]) {
        self.type = MSG_SVR_TIME;
        _svrTime = time;
    }
    return self;
}

@end
