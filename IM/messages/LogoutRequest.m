//
//  LogoutRequest.m
//  WH
//
//  Created by guozw on 14-10-16.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "LogoutRequest.h"
#import "MessageConstants.h"
#import "LogLevel.h"

@implementation LogoutRequest

- (instancetype)init {
    if (self = [super init]) {
        self.type = self.type = MSG_LOGOUT;
    }
    return self;
}

- (NSData *)pkgData {
    DDLogInfo(@"--> log out!");
    return nil;
}


@end
