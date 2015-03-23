//
//  ChatMessageTb.h
//  IM
//
//  Created by 郭志伟 on 15-1-16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "ChatMessage.h"

@interface ChatMessageTb : NSObject

- (instancetype)initWithDbQueue:(FMDatabaseQueue *)dbq;

- (BOOL) updateWithMsgId:(NSString *)msgId status:(ChatMessageStatus) status;

- (BOOL) updateWithMsgId:(NSString *)msgId time:(NSString *)time;

- (BOOL) insertMessage:(ChatMessage *)msg;

- (NSArray *) getMsgsWithId:(NSString *)uid
                    msgType:(ChatMessageType) type
                      limit:(UInt32) limit
                     offset:(UInt32) offset;

- (ChatMessage *)getLastGrpChatMsgByGid:(NSString *)gid;


@end
