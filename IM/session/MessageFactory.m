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
#import "RosterItemAddRequest.h"
#import "RosterItemAddResult.h"
#import "RosterNotification.h"
#import "IMAck.h"
#import "RosterItemNotification.h"
#import "ChatMessage.h"
#import "ChatMessageNotification.h"

@interface MessageFactory()
@end

@implementation MessageFactory

- (Message *)parsePkgWithType:(UInt32)type data:(NSData *)data {
    Message *msg = nil;
    switch (type) {
        case MSG_SVR_TIME:
        {
            NSString *time = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
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
            
        case IM_ROSTER_ITEM_ADD_REQUEST:
        {
            RosterItemAddRequest *riar = [[RosterItemAddRequest alloc] initWithData:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRosterItemAddRequest object:riar];
        }
            break;
        case IM_MESSAGE_ACK:
        {
            IMAck *ack = [[IMAck alloc] initWithData:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:kIMAckNotification object:ack];
        }
            break;
            
        case IM_NOTIFY_ROSTER_ADD:
        {
            RosterItemNotification *n = [[RosterItemNotification alloc] initWithData:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRosterItemAddNotification object:n];
            DDLogInfo(@"INFO: IM_NOTIFY_ROSTER_ADD.");
        }
            break;
        case IM_NOTIFY_ROSTER_DEL:
        {
            RosterItemNotification *n = [[RosterItemNotification alloc] initWithData:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRosterItemDelNotification object:n];
            DDLogInfo(@"INFO: IM_NOTIFY_ROSTER_DEL.");
        }
            break;
           
        case IM_MESSAGE:
        {
            ChatMessage *msg = [[ChatMessage alloc] initWithData:data];
            if (msg) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageRecvNewMsg object:msg];
            }
        }
            break;
            
        case IM_NOTIFY_MESSAGE:
        {
            ChatMessage *msg = [[ChatMessage alloc] initWithData:data];
            if (msg) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageRecvNewMsg object:msg];
            }
        }
        default:
            break;
    }
    return msg;
}


@end
