//
//  Relogin.m
//  IM
//
//  Created by 郭志伟 on 15-1-27.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "Relogin.h"
#import "LoginNotification.h"
#import "session.h"
#import "LoginProcedures.h"
#import "Reachability.h"
#import "LogLevel.h"
#import "AppDelegate.h"

@interface Relogin() <LoginProceduresDelegate> {
    LoginProcedures *m_loginProc;
    BOOL m_login;
}

@end


@implementation Relogin

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLogoff object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (BOOL) setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogin:) name:kNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogOff:) name:kNotificationLogoff object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReachablityNotify:) name:kReachabilityChangedNotification object:nil];
    return YES;
}

- (void) handleLogin:(NSNotification *)notification {
    DDLogInfo(@"INFO: add sessionDied.");
    m_login = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionDied:) name:kSessionDied object:nil];
}


- (void) handleSessionDied:(NSNotification *)notification {
    DDLogCInfo(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionDied object:nil];
    if (APP_DELEGATE.user.kick) {
        return;
    }
    DDLogInfo(@"receive  session died in relogin.");
    if (APP_DELEGATE.reachability.currentReachabilityStatus == NotReachable) {
        DDLogInfo(@"not reachable.");
    } else {
        if (!APP_DELEGATE.user.session.isConnected) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloging object:nil];
            DDLogInfo(@"do reconnect to server.");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (m_loginProc) {
                    [m_loginProc removeObservers];
                }
                [APP_DELEGATE.user reset];
                APP_DELEGATE.user = nil;
                m_loginProc = [[LoginProcedures alloc] init];
                m_loginProc.delegate = self;
                if (![m_loginProc loginWithUserId:self.uid pwd:self.pwd timeout:30]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloginFail object:nil];
                }
            });
        } else {
            DDLogInfo(@"log off.");
        }
    }
}

- (void) handleLogOff:(NSNotification *)notification {
    m_login = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionDied object:nil];
}

- (void) handleReachablityNotify: (NSNotification *) notification {
    DDLogInfo(@"receive a reachablitnotify.");
    if (!m_login) {
        return;
    }

    if (!APP_DELEGATE.user.session.isConnected) {
        if (APP_DELEGATE.user.kick) {
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloging object:nil];
        DDLogInfo(@"do reconnect to server.");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_loginProc) {
                [m_loginProc removeObservers];
            }
            [APP_DELEGATE.user reset];
            APP_DELEGATE.user = nil;
            m_loginProc = [[LoginProcedures alloc] init];
            m_loginProc.delegate = self;
            if (![m_loginProc loginWithUserId:self.uid pwd:self.pwd timeout:30]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloginFail object:nil];
            }
        });
    }
}

- (void)loginProceduresWaitingSvrTime:(LoginProcedures *)proc {
   
}

- (void)loginProcedures:(LoginProcedures *)proc login:(BOOL)suc error:(NSString *)error {
    if (!suc) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloginFail object:nil];
        [m_loginProc stop];
        m_loginProc = nil;
        
    }
}

- (void)loginProcedures:(LoginProcedures *)proc recvPush:(BOOL)suc error:(NSString *)error {
    if (!suc) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloginFail object:nil];
        [m_loginProc stop];
        m_loginProc = nil;
    } else {
        m_login = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionDied:) name:kSessionDied object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloginSuccess object:nil];
        [m_loginProc removeObservers];
        m_loginProc = nil;
    }
}

- (void)loginProceduresConnectFail:(LoginProcedures *)proc timeout:(BOOL)timeout error:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloginFail object:nil];
    [m_loginProc stop];
    m_loginProc = nil;
}

- (void)loginProcedures:(LoginProcedures *)proc getRoster:(BOOL)suc {
    if (!suc) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloginFail object:nil];
        [m_loginProc stop];
        m_loginProc = nil;
    }
}

@end
