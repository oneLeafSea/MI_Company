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
    return YES;
}

@end
