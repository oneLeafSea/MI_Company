//
//  PresenceMsg.m
//  IM
//
//  Created by 郭志伟 on 15-2-19.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "PresenceMsg.h"
#import "MessageConstants.h"
#import "LogLevel.h"

NSString *kPresenceTypeOnline = @"online";
NSString *kPresenceTypeLeave = @"leave";
NSString *kPresenceTypeState = @"state";
NSString *kPresenceTypeAck = @"ack";


NSString *kPresenceShowOnline = @"online";
NSString *kPresenceShowOffline = @"offline";
NSString *kPresenceShowChat = @"chat";
NSString *kPresenceShowDnd = @"dnd";
NSString *kPresenceShowAway = @"away";
NSString *kPresenceShowXa = @"xa";

@implementation PresenceMsg

- (instancetype)init {
    if (self = [super init]) {
        self.type = IM_PRESENCE;
    }
    return self;
}

- (instancetype)initWithPresenceType:(NSString *)presenceType show:(NSString *)presenceShow {
    if (self = [self init]) {
        _show = [presenceShow copy];
        _presenceType = [presenceType copy];
    }
    return self;
}


- (NSData *)pkgData {
    NSDictionary *dict = @{
                           @"msgid": self.qid,
                           @"type" : self.presenceType,
                           @"show" : self.show
                           };
    NSData *data = [self jsonDataFromDict:dict];
    DDLogInfo(@"-->%@", dict);
    return data;
}

@end
