//
//  ChatMessageHistory.h
//  IM
//
//  Created by 郭志伟 on 15/4/27.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface ChatMessageHistory : NSObject

- (instancetype)initWithUser:(User *)user;

- (void) getHistoryMessageWithMsgId:(NSString *)msgId gid:(NSString *)gid completion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion;

- (void) getHistoryMessageWithGid:(NSString *)gid completion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion;

- (void) loadMoreWithCompletion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion;

@property(atomic, readonly)BOOL isLoading;
@property(atomic, readonly)NSUInteger pageSize;
@property(atomic, readonly)NSUInteger cur;

@end
