//
//  AppDelegate.m
//  IM
//
//  Created by guozw on 14/11/24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "AppDelegate.h"

#import <arpa/inet.h>
#import "LogLevel.h"
#import "DDFileLogger.h"
#import "NSUUID+StringUUID.h"
#import "IMConf.h"
#import "RosterMgr.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "FileTransferTask.h"
#import "Utils.h"
#import "FileTransfer.h"
#import "KickNotification.h"
#import <AVFoundation/AVFoundation.h>
#import "Utils.h"
#import "NSData+Conversion.h"
#import "ApnsMgr.h"
#import "RTCPeerConnectionFactory.h"
#import "IM-swift.h"
#import "LoginProcedures.h"
#import "LoginNotification.h"
#import "WelcomeViewController.h"
#import "SDImageCache.h"



@interface AppDelegate () <LoginProceduresDelegate> {
    FileTransferTask *m_fileTask;
    FileTransfer *m_fileTransfer;
     AVAudioRecorder *m;
    LoginProcedures *_loginProc;
}


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    _reachability = [Reachability reachabilityForInternetConnection];
    if (![_reachability startNotifier]) {
        NSAssert(NO, @"Reachablitiy errror!");
    }
    
    
    [SDImageCache sharedImageCache].maxCacheAge = 60 * 60 * 24 * 30; // 一个月
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    [RTCPeerConnectionFactory initializeSSL];
    [IMConf checkLAN:_reachability];
    
    [self initLogger];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKickNotification:) name:kNotificationKick object:nil];
    [self setupApns];
    
    if ([self.reachability currentReachabilityStatus] == NotReachable) {
        return YES;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *uid = [ud objectForKey:@"userId"];
    NSString *pwd = [ud objectForKey:@"pwd"];
    if (uid && pwd) {
        _loginProc = [[LoginProcedures alloc] init];
        _loginProc.delegate = self;
        [_loginProc loginWithUserId:uid pwd:pwd timeout:30];
        WelcomeViewController *wvc = [[WelcomeViewController alloc] init];
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.rootViewController = wvc;
        [self.window makeKeyAndVisible];
        return YES;
    }
   
    return YES;
}

- (void)changeRootViewController:(UIViewController*)viewController {
    
    if (!self.window.rootViewController) {
        self.window.rootViewController = viewController;
        return;
    }
    
    UIView *snapShot = [self.window snapshotViewAfterScreenUpdates:YES];
    
    [viewController.view addSubview:snapShot];
    
    self.window.rootViewController = viewController;
    
    [UIView animateWithDuration:0.5 animations:^{
        snapShot.layer.opacity = 0;
        snapShot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
    } completion:^(BOOL finished) {
        [snapShot removeFromSuperview];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    application.applicationIconBadgeNumber = 0;

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [RTCPeerConnectionFactory deinitializeSSL];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationKick object:nil];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *hex = [deviceToken hexadecimalString];
    DDLogInfo(@"INFO: %@", hex);
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogInfo(@"INFO:%@", error);
}

- (void)initLogger {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    UIColor *green = [UIColor colorWithRed:(0/255.0) green:(125/255.0) blue:(0/255.0) alpha:1.0];
    [[DDTTYLogger sharedInstance] setForegroundColor:green backgroundColor:nil forFlag:LOG_FLAG_INFO];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
}

- (void)handleKickNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Utils alertWithTip:@"账号已在别处登录。"];
    });
    
}

- (void)setupApns {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    UIApplication *app = [UIApplication sharedApplication];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    [app registerUserNotificationSettings:settings];
}

- (void)setUser:(User *)user {
    if (_user) {
        [_user reset];
        _user = nil;
    }
    _user = user;
}

- (NSString *)appVersion {
//    return @"1.0.1"; // 修改了多终端是消息错误的问题，修复重连的问题。
//    return @"1.0.2";   // 修改了webrtc更改了turn服务器
    return @"1.0.3";    // 修改离线消息不能提示的问题，修改通讯录不能点击的问题
    return @"1.0.4";     // 修改消息提示不显示的问题，修改重连的问题
}

- (void)loginProceduresWaitingSvrTime:(LoginProcedures *)proc {
    
}

- (void)loginProcedures:(LoginProcedures *)proc login:(BOOL)suc error:(NSString *)error {
    if (!suc) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginFail object:nil];
    }
}

- (void)loginProcedures:(LoginProcedures *)proc recvPush:(BOOL)suc error:(NSString *)error {
    if (!suc) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginFail object:nil];
    }
}

- (void)loginProceduresConnectFail:(LoginProcedures *)proc timeout:(BOOL)timeout error:(NSError *)error {
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginFail object:nil];
    }
}

- (void)loginProcedures:(LoginProcedures *)proc getRoster:(BOOL)suc {
    if (!suc) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginFail object:nil];
    }
}

@end
