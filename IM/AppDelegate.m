//
//  AppDelegate.m
//  IM
//
//  Created by guozw on 14/11/24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "AppDelegate.h"
#import "LogLevel.h"
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
//#import "WebRtcWebSocketChannel.h"


@interface AppDelegate () {
    FileTransferTask *m_fileTask;
    FileTransfer *m_fileTransfer;
     AVAudioRecorder *m;
}


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [RTCPeerConnectionFactory initializeSSL];
    if ([IMConf isLAN]) {
        [IMConf setIPAndPort:@"10.22.1.47" port:8000];
    } else {
        [IMConf setIPAndPort:@"221.224.159.26" port:48009];
    }
    
    [self initLogger];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _reachability = [Reachability reachabilityForInternetConnection];
    if (![_reachability startNotifier]) {
        NSAssert(NO, @"Reachablitiy errror!");
    }
    self.relogin = [[Relogin alloc] init];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKickNotification:) name:kNotificationKick object:nil];
    [self setupApns];

//    NSURL *url = [NSURL URLWithString:@"ws://10.22.1.153:8088/webrtc"];
//    WebRtcWebSocketChannel *channel = [[WebRtcWebSocketChannel alloc] initWithUrl:url delegate:self];
//    [channel connect];
    
    return YES;
}

//- (void)channel:(WebRtcWebSocketChannel *)channel
// didChangeState:(WebRtcWebSocketChannelState)state {
//    NSLog(@"%d", state);
//}
//
//- (void)channel:(WebRtcWebSocketChannel *)channel
//didReceiveMessage:(WebRtcSignalingMessage *)message {
//    
//}

- (void)timeout {
//    [audioRecorder stop];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

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
//    setenv("XcodeColors", "YES", 0);
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    UIColor *green = [UIColor colorWithRed:(0/255.0) green:(125/255.0) blue:(0/255.0) alpha:1.0];
    [[DDTTYLogger sharedInstance] setForegroundColor:green backgroundColor:nil forFlag:LOG_FLAG_INFO];
}

- (void)handleKickNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Utils alertWithTip:@"账号已在别处登录。"];
    });
    
}

//- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
//    
//}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
//    
//}

- (void)setupApns {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    UIApplication *app = [UIApplication sharedApplication];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    [app registerUserNotificationSettings:settings];
}

@end
