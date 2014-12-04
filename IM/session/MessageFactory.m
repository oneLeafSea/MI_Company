//
//  MessageFactory.m
//  WH
//
//  Created by 郭志伟 on 14-10-14.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "MessageFactory.h"



#import "ObjCMongoDB.h"

#import "Response.h"
#import "LoginResp.h"
#import "ServerTimeMsg.h"
#import "RecvPushResp.h"
#import "LogLevel.h"
#import "Push.h"
#import "MessageConstants.h"

@interface MessageFactory()
@end

@implementation MessageFactory

- (Message *)parsePkgWithType:(UInt32)type data:(NSData *)data {
    Message *msg = nil;
    switch (type) {
        case MSG_SVR_TIME:
        {
            NSString *time = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            msg = [[Message alloc]init];
            ServerTimeMsg *svrMsg = [[ServerTimeMsg alloc]initWithTime:time];
            DDLogInfo(@"<-- %@", time);
            msg = svrMsg;
        }
            break;
        case MSG_LOGIN:
        {
            LoginResp *loginResp = [[LoginResp alloc]init];
            [loginResp parseData:type data:data];
            msg = loginResp;
        }
            break;
        case PUSH_KICK:
        {
            NSString *kickInfo = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            DDLogInfo(@"<-- %@", kickInfo);
        }
            break;
        case MSG_RECEIVE_PUSH:
        {
            RecvPushResp * resp = [[RecvPushResp alloc]init];
            [resp parseData:type data:data];
            msg = resp;
        }
            break;
            
        default:
            break;
    }
    return msg;
}

@end
