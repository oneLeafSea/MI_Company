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
static NSString *const  kNormalQid = @"QID_IM_GET_ROSTER_MSG_HISTORY";
static NSUInteger   kDefaultPageSize = 20;

@interface ChatMessageHistory() {
    __weak User *_user;
    NSArray  *_msgArray;
    ChatMessageType *_msgType;
}
@end

@implementation ChatMessageHistory

- (instancetype)initWithUser:(User *)user {
    if (self == [super init]) {
        _user = user;
        _isLoading = NO;
        _msgArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) getHistoryMessageWithMsgId:(NSString *)msgId
                        chatMsgType:(ChatMessageType)type
                          talkingId:(NSString *)talkingId
                         completion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion {
    _isLoading = YES;
    NSParameterAssert(talkingId);
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:_user.imurl]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:(type == ChatMessageTypeNormal) ? kNormalQid:kQid token:_user.token key:_user.key iv:_user.iv];
    if (type == ChatMessageTypeNormal) {
        [param.params setObject:talkingId forKey:@"msgto"];
        [param.params setObject:[NSString stringWithFormat:@"%lu", (unsigned long)kDefaultPageSize] forKey:@"pagesize"];
        [param.params setObject:[NSString stringWithFormat:@"%lu", (unsigned long)_cur] forKey:@"cur"];
    } else {
        [param.params setObject:talkingId forKey:@"gid"];
        [param.params setObject:[NSString stringWithFormat:@"%lu", (unsigned long)kDefaultPageSize] forKey:@"pagesize"];
        [param.params setObject:[NSString stringWithFormat:@"%lu", (unsigned long)_cur] forKey:@"cur"];
    }
    
    if (msgId) {
        [param.params setObject:msgId forKey:@"msgid"];
    }
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            _isLoading = NO;
            if ([resp isKindOfClass:[JRTableResponse class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    JRTableResponse *tbResp = (JRTableResponse *)resp;
                    [tbResp.result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSArray *array = obj;
                        ChatMessage *msg = [[ChatMessage alloc] initWithNvArray:array chatType:type];
                        ChatMessage *dbMsg = [_user.msgMgr getMsgByMsgId:msg.qid];
                        if (!dbMsg) {
                            [_user.msgMgr insertMsg:msg];
                        }
                    }];
                    _msgArray = [_user.msgMgr loadDbMsgsWithId:talkingId type:type limit:(_cur + 1) * kDefaultPageSize  offset:0];
                    completion(YES, _msgArray);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, nil);
                });
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            DDLogError(@"%@", error);
            _isLoading = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil);
            });
        } cancel:^(JRReqest *request) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _isLoading = NO;
                completion(NO, nil);
            });
        }];
    });
}

- (void) getHistoryMessageWithTalkingId:(NSString *)talkingId
                            chatMsgType:(ChatMessageType)type
                             completion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion {
    _cur = 0;
    [self getHistoryMessageWithMsgId:nil chatMsgType:type talkingId:talkingId completion:^(BOOL finished, NSArray *chatMsgs) {
        completion(finished, chatMsgs);
    }];
}

- (void) loadMoreWithTalkingId:(NSString *)talkingId
                   chatMsgType:(ChatMessageType)type
                    Completion:(void(^)(BOOL finished, NSArray *chatMsgs)) completion {
    _cur++;
    [self getHistoryMessageWithMsgId:nil chatMsgType:type talkingId:talkingId completion:^(BOOL finished, NSArray *chatMsgs) {
        completion(finished, chatMsgs);
    }];
}

- (void)reset {
    _msgArray = [[NSMutableArray alloc] init];
}

@end
