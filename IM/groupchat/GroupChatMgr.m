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
#import "JRTextResponse.h"
#import "ChatMessage.h"
#import "ChatMessageNotification.h"
#import "NSDate+Common.h"
#import "LogLevel.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "GroupChatInviteMsg.h"
#import "GroupChatDelMsg.h"
#import "GroupChatQuitMsg.h"
#import "IMAck.h"
#import "MessageConstants.h"
#import "GroupNotification.h"
#import "GroupChatNotificationTb.h"
#import "GroupChatAcceptMsg.h"
#import "RTSystemSoundPlayer+RTMessages.h"

NSString *kGroupChatListChangedNotification = @"cn.com.rooten.im.groupChatListChangedNotification";

@interface GroupChatMgr() {
    UIBackgroundTaskIdentifier m_task;
}

@property(nonatomic, strong) void (^inviteCallback)(BOOL);
@property(nonatomic, strong) void (^delCallback)(BOOL);
@property(nonatomic, strong) void (^quitCallback)(BOOL);
@property(nonatomic, strong) void (^acceptCallback)(BOOL);
@property(nonatomic, strong) FMDatabaseQueue *dbq;

@property(nonatomic, strong) GroupChatNotificationTb *notifyTb;

@end

@implementation GroupChatMgr

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kIMAckNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGroupChatNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGropuListUpdateNotification object:nil];
}

- (instancetype)init NS_UNAVAILABLE
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithDqb:(FMDatabaseQueue *)dbq {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAckMessage:) name:kIMAckNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupChatNotification:) name:kGroupChatNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGrpListUpdate:) name:kGropuListUpdateNotification object:nil];
        self.dbq = dbq;
        self.notifyTb = [[GroupChatNotificationTb alloc] initWithDbq:dbq];
        if (self.notifyTb == nil) {
            self = nil;
        }
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
                self.grpChatList = [[GroupChatList alloc] initWithGrpInfo:tbResp.result];
                if (self.grpChatList) {
                    if (completion) {
                        completion(YES);
                    }
                } else {
                    if (completion) {
                        completion(NO);
                    }
                }
            } else {
                if (completion) {
                    completion(NO);
                }
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            if (completion) {
                completion(NO);
            }
            
        } cancel:^(JRReqest *request) {
            if (completion) {
                completion(NO);
            }
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
//    ChatMessage *msg = [USER.msgMgr getLastGrpChatMsgWithGid:gid];
//    [param.params setObject:(msg ? msg.time : @"") forKey:gid];
    [param.params setObject:@"" forKey:gid];
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

- (void)createTempGroupWithGName:(NSString *)gName
                           fname:(NSString *)fName
                           token:(NSString *)token
                       signatrue:(NSString *)signature
                             key:(NSString *)key
                              iv:(NSString *)iv
                             url:(NSString *)url
                      completion:(void(^)(NSString* gid, BOOL finished))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_SET_GROUP token:token key:key iv:iv];
    [param.params setObject:gName forKey:@"gname"];
    [param.params setObject:fName forKey:@"fname"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTextResponse class]]) {
                JRTextResponse *txtResp = (JRTextResponse *)resp;
                DDLogInfo(@"gid: %@", txtResp.text);
                completion(txtResp.text, YES);
            } else {
                completion(nil, NO);
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(nil, NO);
            
        } cancel:^(JRReqest *request) {
            completion(nil, NO);
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
        DDLogInfo(@"INFO:update grp time suc.");
        [[UIApplication sharedApplication]  endBackgroundTask: m_task];
        m_task = UIBackgroundTaskInvalid;
    } failure:^(JRReqest *request, NSError *error) {
        DDLogInfo(@"INFO:update grp time fail.");
        [[UIApplication sharedApplication]  endBackgroundTask: m_task];
        m_task = UIBackgroundTaskInvalid;
    } cancel:^(JRReqest *request) {
        DDLogInfo(@"INFO:update grp time fail.");
        [[UIApplication sharedApplication]  endBackgroundTask: m_task];
        m_task = UIBackgroundTaskInvalid;
    }];
}

- (NSArray *)getNotificationCellModels {
    return [self.notifyTb getInvitationNotifcations];
}

- (void)handleWillEnterBackground:(NSNotification *)notification {
    m_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        DDLogInfo(@"INFO: background end.");
        [[UIApplication sharedApplication]  endBackgroundTask: m_task];
        m_task = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         [self updateALLGrpTime];
    });
   
}

- (void)invitePeers:(NSArray *)peers
              toGid:(NSString *)gid
              gname:(NSString *)gname
              session:(Session *)session
         completion:(void(^)(BOOL finished))completion {
    GroupChatInviteMsg *inviteMsg = [[GroupChatInviteMsg alloc] initWithGid:gid type:@"invent" gname:gname peers:peers];
    self.inviteCallback = completion;
    [session post:inviteMsg];
}

- (void)delGrpWithGid:(NSString *)gid
              session:(Session *)session
           completion:(void(^)(BOOL finished))completion {
    GroupChatDelMsg *delMsg = [[GroupChatDelMsg alloc] initWithGid:gid];
    self.delCallback = completion;
    [session post:delMsg];
}

- (void)quitGrpWithGid:(NSString *)gid
               session:(Session *)session
            completion:(void(^)(BOOL finished))completion {
    GroupChatQuitMsg *quitMsg = [[GroupChatQuitMsg alloc] initWithGid:gid];
    self.quitCallback = completion;
    [session post:quitMsg];
}

- (void)acceptGrpWithGid:(NSString *)gid
                   msgid:(NSString *)msgid
                 session:(Session *)session
              completion:(void(^)(BOOL finished))completion {
    GroupChatAcceptMsg *acceptMsg = [[GroupChatAcceptMsg alloc] initWithGid:gid msgid:msgid];
    self.acceptCallback = completion;
    [session post:acceptMsg];
}

- (void)updateNotificationProcessedWithGid:(NSString *)gid {
    [self.notifyTb updateNotificationProcessedWithGid:gid];
}

- (void)clearNotificationDb {
    [self.notifyTb clearDb];
}

- (void)handleAckMessage:(NSNotification *)notifiction {
    dispatch_async(dispatch_get_main_queue(), ^{
        IMAck *ack = notifiction.object;
        if (ack.ackType == IM_CHATROOM) {
            if (ack.error == nil) {
                if (self.inviteCallback) {
                    self.inviteCallback(YES);
                    self.inviteCallback = nil;
                }
                if (self.delCallback) {
                    self.delCallback(YES);
                    self.delCallback = nil;
                    
                }
                
                if (self.quitCallback) {
                    self.quitCallback(YES);
                    self.quitCallback = nil;
                }
                
                if (self.acceptCallback) {
                    self.acceptCallback(YES);
                    self.acceptCallback = nil;
                }
                
            } else {
                if (self.inviteCallback) {
                    self.inviteCallback(NO);
                    self.inviteCallback = nil;
                }
                if (self.delCallback) {
                    self.delCallback(NO);
                    self.delCallback = nil;
                }
                
                if (self.quitCallback) {
                    self.quitCallback(NO);
                    self.quitCallback = nil;
                }
                
                if (self.acceptCallback) {
                    self.acceptCallback(NO);
                    self.acceptCallback = nil;
                }
            }
            
        }
    });
    
}

- (void)handleGroupChatNotification:(NSNotification *)notification {
    [RTSystemSoundPlayer rt_playMessageReceivedSound];
    [[RTSystemSoundPlayer sharedPlayer] playVibrateSound];
    GroupChatNotifyMsg *msg = notification.object;
    NSString *fname = [USER.osMgr getItemInfoByUid:msg.from].name;
    [self.notifyTb insertNotification:msg fromname:fname];
    if ([msg isKindOfClass:[GroupChatNotifyMsg class]]) {
        IMAck *ack = [[IMAck alloc] initWithMsgid:msg.qid ackType:IM_CHATROOM_ACK time:[NSDate stringNow] err:nil];
        [USER.session post:ack];
    }
    [USER.groupChatMgr getGroupListWithToken:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kGroupListUpdateSuccess object:nil];
        }
    }];
    
}

- (void)handleGrpListUpdate:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
       [USER.groupChatMgr getGroupListWithToken:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
           if (finished) {
               [[NSNotificationCenter defaultCenter] postNotificationName:kGroupListUpdateSuccess object:nil];
           }
       }];
    });
}

@end
