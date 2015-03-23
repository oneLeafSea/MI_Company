//
//  groupChatMgr.m
//  IM
//
//  Created by 郭志伟 on 15-3-2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatMgr.h"
#import "JRSession.h"
#import "GroupChatQid.h"
#import "JRTableResponse.h"
#import "ChatMessage.h"
#import "ChatMessageNotification.h"
#import "NSDate+Common.h"
#import "LogLevel.h"
#import "AppDelegate.h"

@interface GroupChatMgr() {
    UIBackgroundTaskIdentifier m_task;
}
@end

@implementation GroupChatMgr

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)getGroupListWithToken:(NSString *)token
                    signature:(NSString *)signature
                          key:(NSString *)key
                           iv:(NSString *)iv
                          url:(NSString *)url
                   completion:(void(^)(BOOL finished))completion{
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_GROUP_LIST token:token key:key iv:iv];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTableResponse class]]) {
                JRTableResponse *tbResp = (JRTableResponse *)resp;
                _grpChatList = [[GroupChatList alloc] initWithGrpInfo:tbResp.result];
                if (_grpChatList) {
                    completion(YES);
                } else {
                    completion(NO);
                }
            } else {
                completion(NO);
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(NO);
            
        } cancel:^(JRReqest *request) {
            completion(NO);
        }];
    });
    
}

- (void)getGroupPeerListWithGid:(NSString *)gid
                          token:(NSString *)token
                      signatrue:(NSString *)signature
                            key:(NSString *)key
                             iv:(NSString *)iv
                            url:(NSString *)url
                     completion:(void(^)(BOOL finished))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_GROUP_PEER_LIST token:token key:key iv:iv];
    [param.params setObject:gid forKey:@"gid"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTableResponse class]]) {
                JRTableResponse *tbResp = (JRTableResponse *)resp;
                GroupChat *grp = [self getGrpChatByGid:gid];
                completion([grp parseItems:tbResp.result]);
            } else {
                completion(NO);
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(NO);
            
        } cancel:^(JRReqest *request) {
            completion(NO);
        }];
    });
}

- (GroupChat *)getGrpChatByGid:(NSString *)gid {
    __block GroupChat *grp = nil;
    [self.grpChatList.grpChatList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GroupChat *group = obj;
        if ([group.gid isEqualToString:gid]) {
            grp = group;
            *stop = YES;
        }
    }];
    return grp;
}

- (void)getGroupOfflineMsgWithGid:(NSString *)gid
                            Token:(NSString *)token
                        signature:(NSString *)signature
                              key:(NSString *)key
                               iv:(NSString *)iv
                              url:(NSString *)url
                       completion:(void(^)(BOOL finished))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_GROUP_OFFLINE_MSG token:token key:key iv:iv];
    ChatMessage *msg = [USER.msgMgr getLastGrpChatMsgWithGid:gid];
    [param.params setObject:(msg ? msg.time : @"") forKey:gid];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTableResponse class]]) {
                JRTableResponse *tbResp = (JRTableResponse *)resp;
                [tbResp.result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSArray *array = obj;
                    ChatMessage *msg = [[ChatMessage alloc] initWithNvArray:array chatType:ChatMessageTypeGroupChat];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageRecvNewMsg object:msg];
                }];
                if (tbResp.result.count > 0) {
                    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
                    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
                    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_RECIVE_GROUP_OFFLINE_MSG token:token key:key iv:iv];
                    NSString *time = [USER.msgMgr getLastGrpChatMsgWithGid:gid].time;
                    [param.params setObject:time forKey:gid];
                    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
                    [session request:req success:^(JRReqest *request, JRResponse *resp) {
                    } failure:^(JRReqest *request, NSError *error) {
                        DDLogCError(@"ERROR:update offine time error");
                    } cancel:^(JRReqest *request) {
                        DDLogCError(@"ERROR:update offine time error");
                    }];
                }
                
                completion(YES);
            } else {
                completion(NO);
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(NO);
            
        } cancel:^(JRReqest *request) {
            completion(NO);
        }];
    });
}

- (void)updateALLGrpTime {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:USER.imurl]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    __block JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_RECIVE_GROUP_OFFLINE_MSG token:USER.token key:USER.key iv:USER.iv];
    [self.grpChatList.grpChatList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GroupChat *gc = obj;
        ChatMessage *msg = [USER.msgMgr getLastGrpChatMsgWithGid:gc.gid];
        if (msg) {
            [param.params setObject:msg.time forKey:gc.gid];
        }
    }];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    [session request:req success:^(JRReqest *request, JRResponse *resp) {
        NSLog(@"INFO:update grp time suc.");
        [[UIApplication sharedApplication]  endBackgroundTask: m_task];
        m_task = UIBackgroundTaskInvalid;
    } failure:^(JRReqest *request, NSError *error) {
        NSLog(@"INFO:update grp time fail.");
        [[UIApplication sharedApplication]  endBackgroundTask: m_task];
        m_task = UIBackgroundTaskInvalid;
    } cancel:^(JRReqest *request) {
        NSLog(@"INFO:update grp time fail.");
        [[UIApplication sharedApplication]  endBackgroundTask: m_task];
        m_task = UIBackgroundTaskInvalid;
    }];
}

- (void)handleWillEnterBackground:(NSNotification *)notification {
    m_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"INFO: background end.");
        [[UIApplication sharedApplication]  endBackgroundTask: m_task];
        m_task = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         [self updateALLGrpTime];
    });
   
}

@end
