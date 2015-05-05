//
//  ChatMessageHistory.h
//  IM
//
//  Created by 郭志伟 on 15/4/27.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"

@class User;

@interface ChatMessageHistory : NSObject

- (instancetype)initWithUser:(User *)user;

- (void) getHistoryMessageWithMsgId:(NSString *)msgId
                        chatMsgType:(ChatMessageType)type
                          talkingId:(NSString *)talkingId
                         completion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion;

- (void) getHistoryMessageWithTalkingId:(NSString *)talkingId
                      chatMsgType:(ChatMessageType)type
                       completion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion;

- (void) loadMoreWithTalkingId:(NSString *)talkingId
             chatMsgType:(ChatMessageType)type
              Completion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion;

- (void)reset;

@property(atomic, readonly)BOOL isLoading;
@property(atomic, readonly)NSUInteger pageSize;
@property(atomic)   NSUInteger cur;

@end
