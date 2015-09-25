//
//  GroupChatJoinMsg.m
//  IM
//
//  Created by 郭志伟 on 15/9/24.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatJoinMsg.h"
#import "MessageConstants.h"
#import "LogLevel.h"

@implementation GroupChatJoinMsg

- (instancetype)initWithData:(NSData *)data {
    if (self = [self init]) {
        if (![self parseData:data]) {
            self = nil;
        }
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = IM_NOTIFY_GROUP_JOIN_SUCCESS;
    }
    return self;
}

- (BOOL)parseData:(NSData *)data {
    NSDictionary *dict = [self dictFromJsonData:data];
    DDLogInfo(@"<-- %@", dict);
    _gid = [[dict objectForKey:@"gid"] copy];
    _uid = [[dict objectForKey:@"uid"] copy];
    return YES;
}

@end
