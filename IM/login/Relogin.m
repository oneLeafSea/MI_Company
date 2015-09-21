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
#import "IMConf.h"
#import "AppDelegate.h"

@interface Relogin() <LoginProceduresDelegate> {
    LoginProcedures *m_loginProc;
   
}

@property(atomic) BOOL logining;

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (BOOL) setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogin:) name:kNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogOff:) name:kNotificationLogoff object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReachablityNotify:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppEnterForground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    return YES;
}

- (void) handleLogin:(NSNotification *)notification {
    self.logining = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionDied:) name:kSessionDied object:nil];
}


- (void) handleSessionDied:(NSNotification *)notification {
    self.logining = NO;
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
                if (APP_DELEGATE.reachability.currentReachabilityStatus != NotReachable) {
                    if (m_loginProc) {
                        [m_loginProc removeObservers];
                    }
                    [IMConf checkLAN:APP_DELEGATE.reachability];
                    self.logining = YES;
                    m_loginProc = [[LoginProcedures alloc] init];
                    m_loginProc.delegate = self;
                    
                    if (![m_loginProc loginWithUserId:self.uid pwd:self.pwd timeout:30]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloginFail object:nil];
                    }                }
            });
        } else {
            DDLogInfo(@"log off.");
        }
    }
}

- (void) handleLogOff:(NSNotification *)notification {
    self.logining = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionDied object:nil];
}

- (void) handleReachablityNotify: (NSNotification *) notification {
    DDLogInfo(@"receive a reachablitnotify.");
    if (self.logining) {
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
        self.logining = YES;
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
    self.logining = NO;
    if (APP_DELEGATE.reachability.currentReachabilityStatus != NotReachable) {
        m_loginProc = [[LoginProcedures alloc] init];
        m_loginProc.delegate = self;
        if (![m_loginProc loginWithUserId:self.uid pwd:self.pwd timeout:30]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloginFail object:nil];
        }
    }
}

- (void)loginProcedures:(LoginProcedures *)proc getRoster:(BOOL)suc {
    if (!suc) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloginFail object:nil];
        [m_loginProc stop];
        m_loginProc = nil;
    }
}

- (void)handleAppEnterForground:(NSNotification *)notification {
    if (!USER.session.isConnected && APP_DELEGATE.reachability.currentReachabilityStatus != NotReachable && !USER.kick && self.uid != nil && self.pwd != nil) {
        [IMConf checkLAN:APP_DELEGATE.reachability];
        m_loginProc = [[LoginProcedures alloc] init];
        m_loginProc.delegate = self;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloging object:nil];
        if (![m_loginProc loginWithUserId:self.uid pwd:self.pwd timeout:30]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloginFail object:nil];
        }
    }
}

@end
