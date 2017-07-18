//
//  RecvPushResp.m
//  WH
//
//  Created by guozw on 14-10-16.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RecvPushResp.h"
#import "LogLevel.h"

@implementation RecvPushResp

- (BOOL)parseData:(UInt32)type data:(NSData *)data {
     _respData = [self dictFromJsonData:data];
    self.qid = [_respData objectForKey:@"qid"];
    self.type = type;
   
    DDLogInfo(@"<-- %@", _respData);
    return YES;
}

@end
