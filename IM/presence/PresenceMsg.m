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
NSString *kPresenceTypeUpdate = @"update";
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

- (instancetype)initWithData:(NSData *)data {
    if (self = [self init]) {
        if (![self parseData:data]) {
            self = nil;
        }
    }
    return self;
}


- (NSData *)pkgData {
    
    NSDictionary *dict = nil;
    if ([self.presenceType isEqualToString:kPresenceTypeAck]) {
        dict = @{
                   @"msgid": self.qid,
                   @"type" : self.presenceType,
                   @"show" : self.show,
                   @"to"   : self.to,
                   @"to_res" : self.to_res,
                   @"sign": self.sign ? self.sign : @""
                   };
    } else {
        dict = @{
                   @"msgid": self.qid,
                   @"type" : self.presenceType,
                   @"show" : self.show,
                   @"sign": self.sign ? self.sign : @""
                   };
    }
    
    NSData *data = [self jsonDataFromDict:dict];
    DDLogInfo(@"-->%@", dict);
    return data;
}

- (BOOL)parseData:(NSData *)data {
    NSDictionary *dict = [self dictFromJsonData:data];
    DDLogInfo(@"<-- %@", dict);
    _from = [[dict objectForKey:@"from"] copy];
    _from_res = [[dict objectForKey:@"from_res"] copy];
    self.qid = [[dict objectForKey:@"msgid"] copy];
    _show = [dict objectForKey:@"show"];
    _presenceType = [dict objectForKey:@"type"];
    return YES;
}

@end
