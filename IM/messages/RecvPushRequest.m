//
//  RecvPushRequest.m
//  WH
//
//  Created by guozw on 14-10-16.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RecvPushRequest.h"
#import "MessageConstants.h"
#import "LogLevel.h"

@implementation RecvPushRequest

- (instancetype)init {
    if (self = [super init]) {
        self.type = MSG_RECEIVE_PUSH;
    }
    return self;
}

- (NSData *)pkgData {
    NSDictionary *dict = @{kMsgQid : self.qid};
    DDLogInfo(@"--> %@", dict);
    NSData *data = [self jsonDataFromDict:dict];
    return data;
}

@end
