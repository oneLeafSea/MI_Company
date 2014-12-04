//
//  LoginResp.m
//  WH
//
//  Created by guozw on 14-10-15.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "LoginResp.h"
#import "LogLevel.h"

@implementation LoginResp


- (BOOL)parseData:(UInt32)type data:(NSData *)data {
    self.type = type;
    _respData = [self dictFromJsonData:data];
    DDLogInfo(@"<-- %@", _respData);
    self.qid = [_respData objectForKey:@"qid"];
    return YES;
}

@end
