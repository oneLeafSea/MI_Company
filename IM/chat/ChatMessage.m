//
//  ChatMessage.m
//  IM
//
//  Created by 郭志伟 on 15-1-14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessage.h"
#import "MessageConstants.h"
#import "LogLevel.h"

@interface ChatMessage()

@end

@implementation ChatMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = IM_MESSAGE;
        self.body = [[NSMutableDictionary alloc] init];
        self.fromRes = @"unkown";
        self.toRes = @"unkown";
        self.status = ChatMessageStatusUnkown;
    }
    return self;
}

- (instancetype) initWithData:(NSData *)data {
    if (self = [self init]) {
        if (![self parseData:data]) {
            self = nil;
        }
        self.toRes = @"iphone";
    }
    return  self;
}

- (NSData *)pkgData {
    NSData *bodydata = [self jsonDataFromDict:self.body];
    NSString *body = [[NSString alloc] initWithData:bodydata encoding:NSUTF8StringEncoding];
    NSDictionary *dict = @{
                           @"from" : self.from,
                           @"to"   : self.to,
                           @"time" : self.time,
                           @"body" : body,
                           @"msgid": self.qid,
                           @"type" : [NSNumber numberWithUnsignedInt:self.chatMsgType],
                           @"fromRes":@"iphone"
                           };
    DDLogInfo(@"--> %@", dict);
    NSData *data = [self jsonDataFromDict:dict];
    return data;
}

- (BOOL)parseData:(NSData *)data {
    NSDictionary *dict = [self dictFromJsonData:data];
    DDLogInfo(@"<--%@", dict);
    NSString *strBody = [dict objectForKey:@"body"];
    NSData *bodyData = [strBody dataUsingEncoding:NSUTF8StringEncoding];
    self.body = [[NSMutableDictionary alloc] initWithDictionary:[self dictFromJsonData:bodyData]];
    self.from = [dict objectForKey:@"from"];
    self.to = [dict objectForKey:@"to"];
    self.time = [dict objectForKey:@"time"];
    self.qid = [dict objectForKey:@"msgid"];
    self.fromRes = [dict objectForKey:@"from_res"];
    self.chatMsgType = [[dict objectForKey:@"type"] intValue];
    return YES;
}

- (instancetype) initWithNvArray:(NSArray *)nvArray chatType:(ChatMessageType)type {
    if (self = [self init]) {
        if (![self parseNvArray:nvArray]) {
            self = nil;
        }
        self.chatMsgType = type;
    }
    return self;
}

- (BOOL) parseNvArray:(NSArray *)nvArray {
    if (!nvArray) {
        return NO;
    }
    [nvArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = obj;
        NSString *n = [dict objectForKey:@"n"];
        NSString *v = [dict objectForKey:@"v"];
        if ([n isEqualToString:@"msgid"]) {
            self.qid = [v copy];
            return;
        }
        if ([n isEqualToString:@"body"]) {
            NSData *bodyData = [v dataUsingEncoding:NSUTF8StringEncoding];
            self.body = [[NSMutableDictionary alloc] initWithDictionary:[self dictFromJsonData:bodyData]];
            return;
        }
        
        if ([n isEqualToString:@"from"]) {
            self.from = [v copy];
            return;
        }
        
        if ([n isEqualToString:@"to"]) {
            self.to = [v copy];
            return;
        }
        
        if ([n isEqualToString:@"time"]) {
            self.time = [v copy];
            return;
        }
    }];
    return YES;
}

@end
