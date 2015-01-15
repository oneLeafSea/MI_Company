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
    }
    return self;
}

- (instancetype) initWithData:(NSData *)data {
    if (self = [self init]) {
        if (![self parseData:data]) {
            self = nil;
        }
    }
    return  self;
}

- (NSData *)pkgData {
    NSDictionary *dict = @{
                           @"from" : self.from,
                           @"to"   : self.to,
                           @"time" : self.time,
                           @"body" : self.body,
                           @"msgid": self.qid,
                           @"type" : [NSNumber numberWithUnsignedInt:self.chatMsgType],
                           };
    DDLogInfo(@"--> %@", dict);
    NSData *data = [self jsonDataFromDict:dict];
    return data;
}

- (BOOL)parseData:(NSData *)data {
    NSDictionary *dict = [self dictFromJsonData:data];
    DDLogInfo(@"<--%@", dict);
    self.body = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKeyedSubscript:@"body"]];
    self.from = [dict objectForKey:@"from"];
    self.to = [dict objectForKey:@"to"];
    self.time = [dict objectForKey:@"time"];
    self.qid = [dict objectForKey:@"msgid"];
    self.fromRes = [dict objectForKey:@"from_res"];
    return YES;
}
@end
