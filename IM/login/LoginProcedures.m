//
//  LoginProcedures.m
//  WH
//
//  Created by guozw on 14-10-16.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "LoginProcedures.h"

#import "MessageConstants.h"

#import "LoginRequest.h"
#import "LoginResp.h"

#import "RecvPushRequest.h"
#import "RecvPushResp.h"

#import "LogLevel.h"
#import "AppDelegate.h"
#import "LoginNotification.h"
#import "PresenceMsg.h"
#import "GroupChat.h"
#import "ApnsMgr.h"

#import "Encrypt.h"
#import "NSString+URL.h"
#import "NSDate+Common.h"
#import "NSUUID+StringUUID.h"
#import "IMConf.h"

#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/UIImageView+WebCache.h>



@interface LoginProcedures() <RequestDelegate>
{
    Session         *m_sess;
    BOOL            m_stop;
}

@end

@implementation LoginProcedures


#if DEBUG
- (void)dealloc {
    DDLogInfo(@"%@ dealloc", NSStringFromClass([self class]));
    [self removeObservers];
}
#endif

- (BOOL)loginWithUserId:(NSString *)userId
                     pwd:(NSString *)pwd
                 timeout:(NSTimeInterval)timeout {
    m_sess = [[Session alloc] init];
    m_stop = NO;
    _userId = userId;
    _pwd = pwd;
    [IMConf checkLAN:APP_DELEGATE.reachability];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *IP = [ud objectForKey:@"IP"];
    NSNumber *port = [ud objectForKey:@"port"];
    NSLog(@"IP: %@, port:%@", IP, port);
    if (!IP || !port) {
        DDLogError(@"ERROR: IP or port is nil.");
        return NO;
    }
    [self addObservers];
    return [m_sess connectToIP:IP port:[port unsignedIntValue]  TLS:YES timeout:timeout];
}

- (void)sendRecvPushRequest {
    if (m_stop) return;
    RecvPushRequest *req = [[RecvPushRequest alloc]init];
    req.delegate = self;
    [m_sess request:req];
}

- (void)getGroupList {
    if (m_stop) return;
    [USER.groupChatMgr getGroupListWithToken:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
        DDLogInfo(@"get grp list");
        if (finished) {
            [self sendRecvPushRequest];
        } else {
            [self stop];
        }
        
    }];
}

- (void)setWebImgCfg {
    SDWebImageDownloader *manager = [SDWebImageDownloader sharedDownloader];
    NSString *qid = [NSString stringWithFormat:@"%@|%@", [NSUUID uuid], [[NSDate Now] formatWith:nil]];
    NSString *key = USER.key;
    NSString *iv = USER.iv;
    NSString *sign = [Encrypt encodeWithKey:key iv:iv data:[qid dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    [manager setValue:[USER.token URLEncodedString] forHTTPHeaderField:@"rc-token"];
    [manager setValue:[qid URLEncodedString] forHTTPHeaderField:@"rc-qid"];
    [manager setValue:[sign URLEncodedString] forHTTPHeaderField:@"rc-signature"];
}

- (void)saveUseIdAndPwd {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:_userId forKey:@"userId"];
    [ud setObject:_pwd forKey:@"pwd"];
    [ud synchronize];
}


- (void)stop {
    m_stop = YES;
    [self removeObservers];
    [m_sess disconnect];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionConneted:) name:kSessionConnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionServerTime:) name:kSessionServerTime object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionDied:) name:kSessionDied object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionTimeout:) name:kSessionTimeout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionConnectFail:) name:kSessionConnectedFail object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionConnected object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionServerTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionTimeout object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionDied object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionConnectedFail object:nil];
}


#pragma mark - request delegate

- (void)request:(Request *)req response:(Response *)resp {
    if (m_stop) return;
    switch (resp.type) {
        case MSG_LOGIN:
        {
            LoginResp *loginResp = (LoginResp *)resp;
            NSString *err = [loginResp.respData objectForKey:@"error"];
            if (err) {
                [self removeObservers];
                if ([self.delegate respondsToSelector:@selector(loginProcedures:login:error:)]) {
                    [self.delegate loginProcedures:self login:NO error:err];
                }
            } else {
                AppDelegate *dgt = [UIApplication sharedApplication].delegate;
                dgt.user = [[User alloc] initWithLoginresp:loginResp session:m_sess];
                dgt.user.pwd = [self.pwd copy];
                dgt.relogin = [Relogin instance];
                dgt.relogin.uid = [dgt.user.uid copy];
                dgt.relogin.pwd = dgt.user.pwd;
                if ([self.delegate respondsToSelector:@selector(loginProcedures:login:error:)]) {
                    [self.delegate loginProcedures:self login:YES error:nil];
                }
                [dgt.user.rosterMgr getRosterWithKey:dgt.user.key iv:dgt.user.iv url:dgt.user.imurl token:dgt.user.token completion:^(BOOL finished) {
                    if ([self.delegate respondsToSelector:@selector(loginProcedures:getRoster:)]) {
                        [self.delegate loginProcedures:self getRoster:finished];
                    }
                    if (finished) {
                        [self getGroupList];
                        [USER.detailMgr getDetailWithUid:USER.uid Token:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished, Detail *d) {
                            if (finished) {
                                USER.mineDetail = d;
//                                USER.signature = [USER.rosterMgr signature];
                            } else {
                                DDLogError(@"ERROR: get detail info.");
                            }
                        }];
                        
                    } else {
                        [self stop];
                    }
                }];
            }
            
        }
            break;
            
        case MSG_RECEIVE_PUSH:
        {
            [self removeObservers];
            RecvPushResp *pushResp = (RecvPushResp *)resp;
            NSString *err = [pushResp.respData objectForKey:@"error"];
            if ([self.delegate respondsToSelector:@selector(loginProcedures:recvPush:error:)]) {
                [self.delegate loginProcedures:self recvPush:err ? NO:YES error:err];
            }
            
            dispatch_group_t waitGroup = dispatch_group_create();
            
            dispatch_group_enter(waitGroup);
            [USER.avatarMgr syncAvatarVerWithCompletion:^(BOOL finished, NSError *error) {
                NSMutableArray *uids = [[NSMutableArray alloc] initWithArray:[USER.rosterMgr getRosterAllUids]];
                [uids addObject:USER.uid];
                [USER.avatarMgr getAvatarsByUserIds:uids];
                dispatch_group_leave(waitGroup);
            }];
            
            [USER.groupChatMgr.grpChatList.grpChatList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                __block GroupChat *gc = obj;
                [USER.groupChatMgr getGroupOfflineMsgWithGid:gc.gid Token:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
                    
                    if (!finished) {
                        DDLogError(@"ERROR: get {gid:%@, gname:%@} offline msg error.", gc.gid, gc.gname);
                    }
                }];
                
            }];
            
            dispatch_group_enter(waitGroup);
            [USER.osMgr syncOrgStructWithWithToken:USER.token signature:USER.signature key:USER.key iv:USER.iv url:USER.imurl completion:^(BOOL finished) {
                dispatch_group_leave(waitGroup);
            }];
            
            
            
            dispatch_group_notify(waitGroup,dispatch_get_main_queue(),^{
                [USER.presenceMgr postMsgWithPresenceType:kPresenceTypeOnline presenceShow:kPresenceShowOnline];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccess object:nil];
                [self setWebImgCfg];
                [self saveUseIdAndPwd];
            });
            
            
           
//            [ApnsMgr registerWithIOSToken:@"e34f50d210d3b77bc43692791c605135d044696ee94184b4b309447c0f3728a6" uid:@"gzw" Token:USER.token signature:USER.signature key:USER.key iv:USER.iv url:@"http://127.0.0.1:8080/register" completion:^(BOOL finished) {
//                    DDLogInfo(@"%d", finished);
//                
//            }]
            
        }
            break;
        default:
            break;
    }
}


- (void)request:(Request *)req error:(NSError *)error {
    if (m_stop) return;
    
}




#pragma mark - session notification.
- (void)handleSessionConneted: (NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(loginProceduresWaitingSvrTime:)]) {
        [self.delegate loginProceduresWaitingSvrTime:self];
    }
}

- (void)handleSessionServerTime: (NSNotification *)notification {
    LoginRequest *req = [[LoginRequest alloc]initWithUserId:self.userId pwd:self.pwd];
    req.delegate = self;
    [m_sess request:req];
}

- (void)handleSessionDied:(NSNotification *)notification {
    [self removeObservers];
    if ([self.delegate respondsToSelector:@selector(loginProceduresConnectFail:timeout:error:)]) {
        [self.delegate loginProceduresConnectFail:self timeout:NO error:[[NSError alloc] initWithDomain:@"login" code:4000 userInfo:@{@"error": @"服务器已断开！"}]];
    }
}

- (void)handleSessionTimeout:(NSNotification *)notification {
    [self removeObservers];
    if ([self.delegate respondsToSelector:@selector(loginProceduresConnectFail:timeout:error:)]) {
        [self.delegate loginProceduresConnectFail:self timeout:YES error:[[NSError alloc] initWithDomain:@"login" code:4000 userInfo:@{@"error": @"连接服务器超时！"}]];
    }
}

- (void)handleSessionConnectFail:(NSNotification *)notification {
    [self removeObservers];
    if ([self.delegate respondsToSelector:@selector(loginProceduresConnectFail:timeout:error:)]) {
        [self.delegate loginProceduresConnectFail:self timeout:YES error:[[NSError alloc] initWithDomain:@"login" code:4000 userInfo:@{@"error": @"连接服务器失败！"}]];
    }
}

@end
