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


@interface LoginProcedures() <RequestDelegate>
{
    Session *m_sess;
    BOOL            m_stop;
}

@end

@implementation LoginProcedures

- (BOOL)loginWithUserId:(NSString *)userId
                     pwd:(NSString *)pwd
                 timeout:(NSTimeInterval)timeout {
    m_sess = [[Session alloc] init];
    m_stop = NO;
    _userId = userId;
    _pwd = pwd;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *IP = [ud objectForKey:@"IP"];
    NSNumber *port = [ud objectForKey:@"port"];
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
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionConnected object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionServerTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionTimeout object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionDied object:nil];
}


#pragma mark - request delegate

- (void)request:(Request *)req response:(Response *)resp {
    if (m_stop) return;
    switch (resp.type) {
        case MSG_LOGIN:
        {
            LoginResp *loginResp = (LoginResp *)resp;
            AppDelegate *dgt = [UIApplication sharedApplication].delegate;
            dgt.user = [[User alloc] initWithLoginresp:loginResp session:m_sess];
            if ([self.delegate respondsToSelector:@selector(loginProcedures:login:)]) {
                [self.delegate loginProcedures:self login:YES];
            }
            [self sendRecvPushRequest];
        }
            break;
            
        case MSG_RECEIVE_PUSH:
        {
            RecvPushResp *pushResp = (RecvPushResp *)resp;
            if ([self.delegate respondsToSelector:@selector(loginProcedures:recvPush:)]) {
                [self.delegate loginProcedures:self recvPush:YES];
            }
            [self removeObservers];
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
}

- (void)handleSessionTimeout:(NSNotification *)notification {
    
}

@end
