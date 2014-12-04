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


@interface LoginProcedures() <RequestDelegate, SessionDelegate>
{
    __weak Session *m_sess;
    BOOL            m_stop;
}

@end

@implementation LoginProcedures

- (BOOL)loginWithSession:(Session *)sess
                  UserId:(NSString *)userId
                     pwd:(NSString *)pwd
                 timeout:(NSTimeInterval)timeout {
    if (!sess) {
        DDLogError(@"session is nil.");
        return NO;
    }
    m_sess = sess;
    sess.delegate = self;
    m_stop = NO;
    _userId = userId;
    _pwd = pwd;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *IP = [ud objectForKey:@"IP"];
    NSNumber *port = [ud objectForKey:@"port"];
    if (!IP || !port) {
        DDLogError(@"IP or port is nil");
        return NO;
    }
    return [sess connectToIP:IP port:[port unsignedIntValue]  TLS:YES timeout:timeout];
}

- (void)sendRecvPushRequest {
    if (m_stop) return;
    RecvPushRequest *req = [[RecvPushRequest alloc]init];
    req.delegate = self;
    [m_sess request:req];
}

- (void)stop {
    m_stop = YES;
    [m_sess disconnect];
}


#pragma mark - request delegate

- (void)request:(Request *)req response:(Response *)resp {
    if (m_stop) return;
    switch (resp.type) {
        case MSG_LOGIN:
        {
//            LoginResp *loginResp = (LoginResp *)resp;
            
            if ([self.delegate respondsToSelector:@selector(loginProcedures:login:)]) {
                [self.delegate loginProcedures:self login:YES];
            }
//            AppDelegate *dlgt = [[UIApplication sharedApplication] delegate];
//            dlgt.userInfo = loginResp.respData;
            [self sendRecvPushRequest];
        }
            break;
            
        case MSG_RECEIVE_PUSH:
        {
            RecvPushResp *pushResp = (RecvPushResp *)resp;
            DDLogInfo(@"<-- %@", pushResp.respData);
            if ([self.delegate respondsToSelector:@selector(loginProcedures:recvPush:)]) {
                [self.delegate loginProcedures:self recvPush:YES];
            }
        }
            
        default:
            break;
    }
}

- (void)request:(Request *)req error:(NSError *)error {
    if (m_stop) return;
    
}

#pragma mark - sessiondelegate
- (void)session:(Session *)sess connected:(BOOL)connected timeout:(BOOL)timeout error:(NSError *)error {
    if (connected) {
        if ([self.delegate respondsToSelector:@selector(loginProceduresWaitingSvrTime:)]) {
            [self.delegate loginProceduresWaitingSvrTime:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(loginProceduresConnectFail:timeout:error:)]) {
            [self.delegate loginProceduresConnectFail:self timeout:timeout error:error];
        }
    }
}

- (void)session:(Session *)sess serverTime:(NSString *)serverTime {
    LoginRequest *req = [[LoginRequest alloc]initWithUserId:self.userId pwd:self.pwd];
    req.delegate = self;
    [sess request:req];
}

- (void)sessionDied:(Session *)sess error:(NSError *)err {

}

@end
