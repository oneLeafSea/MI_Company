//
//  FCMgr.h
//  IM
//
//  Created by 郭志伟 on 15/6/17.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface FCMgr : NSObject

- (instancetype)initWithUser:(User *)user;

- (void)getMsgsWithCur:(NSUInteger)cur
                  pgSz:(NSUInteger)pgSz
            completion:(void(^)(BOOL finished, NSDictionary *result))completion;

- (void)postANewMsg;

- (void)NewPostWithContent:(NSString *)content
                    imgs:(NSArray *)imgs
                completion:(void(^)(BOOL finished))completion;


- (void)replyMsgWithId:(NSString *)msgId
               replyId:(NSString *)replyId
              replyUid:(NSString *)replyUid
               content:(NSString *)content
            completion:(void(^)(BOOL finished))completion;

@end
