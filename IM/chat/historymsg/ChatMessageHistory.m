//
//  ChatMessageHistroy.m
//  IM
//
//  Created by 郭志伟 on 15/4/27.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageHistory.h"
#import "JRSession.h"
#import "JRTableResponse.h"
#import "user.h"
#import "LogLevel.h"

static NSString * const kQid = @"QID_IM_GET_GROUP_MSG_HISTORY";
static NSUInteger   kDefaultPageSize = 50;

@interface ChatMessageHistory() {
    __weak User *_user;
}
@end

@implementation ChatMessageHistory

- (instancetype)initWithUser:(User *)user {
    if (self == [super init]) {
        _user = user;
        _isLoading = NO;
    }
    return self;
}

- (void) getHistoryMessageWithMsgId:(NSString *)msgId
                                gid:(NSString *)gid
                         completion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion {
    NSParameterAssert(gid);
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:_user.imurl]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:kQid token:_user.token key:_user.key iv:_user.iv];
    [param.params setObject:gid forKey:@"gid"];
    [param.params setObject:[NSString stringWithFormat:@"%lu", (unsigned long)kDefaultPageSize] forKey:@"pagesize"];
    [param.params setObject:@"0" forKey:@"cur"];
    
    if (msgId) {
        [param.params setObject:msgId forKey:@"msgid"];
    }
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTableResponse class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES, nil);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, nil);
                });
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            DDLogError(@"%@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil);
            });
        } cancel:^(JRReqest *request) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil);
            });
        }];
    });
}

- (void) getHistoryMessageWithGid:(NSString *)gid
                       completion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion {
    [self getHistoryMessageWithMsgId:nil gid:gid completion:^(BOOL finished, NSArray *chatMsgs) {
        completion(finished, chatMsgs);
    }];
}

- (void) loadMoreWithCompletion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion {
    
}

@end
