//
//  GroupChatNotifyMsg.m
//  IM
//
//  Created by 郭志伟 on 15/9/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatNotifyMsg.h"
#import "LogLevel.h"
#import "MessageConstants.h"

@implementation GroupChatNotifyMsg

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        if (![self parseData:data]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)parseData:(NSData *)data {
    self.type = IM_CHATROOM;
    NSDictionary *dict = [self dictFromJsonData:data];
    DDLogInfo(@"<-- %@", dict);
    self.qid = [dict objectForKey:@"msgid"];
    if (self.qid == nil) {
        DDLogError(@"ERROR: GroupChatNotifyMsg do not have msgid key.");
        return NO;
    }
    _from = [[dict objectForKey:@"from"] copy];
    _from_res = [[dict objectForKey:@"from_res"] copy];
    _gid = [[dict objectForKey:@"gid"] copy];
    _gname = [[dict objectForKey:@"gname"] copy];
    _to = [[dict objectForKey:@"to"] copy];
    _notifytype = [[dict objectForKey:@"type"] copy];
    return YES;
}

@end
