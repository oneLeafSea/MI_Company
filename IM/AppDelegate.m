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

@interface AppDelegate () {
    FileTransferTask *m_fileTask;
    FileTransfer *m_fileTransfer;
}


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [IMConf setIPAndPort:@"10.22.1.112" port:8000];
    [self initLogger];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _reachability = [Reachability reachabilityForInternetConnection];
    if (![_reachability startNotifier]) {
        NSAssert(NO, @"Reachablitiy errror!");
    }
    self.relogin = [[Relogin alloc] init];
//    NSString *fileName = @"otp_win64_17.3.exe";
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
//    NSString *path = [[Utils documentPath] stringByAppendingPathComponent:fileName];
//    NSDictionary *options = @{
//                              @"path":path,
//                              @"token":@"token123123",
//                              @"signature":@"signature12312123"
//                              };
//    m_fileTask = [[FileTransferTask alloc] initWithFileName:fileName
//                                                  urlString:@"http://10.22.1.112:8040/file/download"
//                                             checkUrlString:@"http://10.22.1.112:8040/file/check"
//                                                   taskType:FileTransferTaskTypeDownload options:options];
//    [m_fileTask start];
    
    m_fileTransfer = [[FileTransfer alloc] init];
    __block NSString *fileName = [NSString stringWithFormat:@"%d.exe", 90];
    NSString *path = [[Utils documentPath] stringByAppendingPathComponent:fileName];
    NSDictionary *options = @{
                              @"path":path,
                              @"token":@"token123123",
                              @"signature":@"signature12312123"
                              };
    [m_fileTransfer downloadFileName:fileName urlString:@"http://10.22.1.112:8040/file/download" checkUrlString:@"http://10.22.1.112:8040/file/check" options:options completion:^(BOOL finished, NSError *error) {
        if (finished) {
            DDLogInfo(@"finished");
        } else {
            DDLogInfo(@"ERROR:%@", error);
        }
    }];
    
//    for (int n = 0; n < 9; n++) {
//        __block NSString *fileName = [NSString stringWithFormat:@"%d.exe", n];
//        NSString *path = [[Utils documentPath] stringByAppendingPathComponent:fileName];
//        NSDictionary *options = @{
//                                  @"path":path,
//                                  @"token":@"token123123",
//                                  @"signature":@"signature12312123"
//                                  };
//        if (n%2 == 0) {
//            [m_fileTransfer uploadFileName:fileName urlString:@"http://10.22.1.112:8040/file/upload" checkUrlString:@"http://10.22.1.112:8040/file/check" options:options completion:^(BOOL finished, NSError *error) {
//                if (finished) {
//                    DDLogInfo(@"%@ upload!", fileName);
//                } else {
//                    DDLogInfo(@"%@ not upload!", fileName);
//                }
//                
//            }];
//        } else {
//            [m_fileTransfer downloadFileName:fileName urlString:@"http://10.22.1.112:8040/file/download" checkUrlString:@"http://10.22.1.112:8040/file/check" options:options completion:^(BOOL finished, NSError *error) {
//                if (finished) {
//                    DDLogInfo(@"%@ upload!", fileName);
//                } else {
//                    DDLogInfo(@"%@ not upload!", fileName);
//                }
//                
//            }];
//        }
//        
//    }
    
    return YES;
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
}

- (void)initLogger {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    UIColor *green = [UIColor colorWithRed:(0/255.0) green:(125/255.0) blue:(0/255.0) alpha:1.0];
    [[DDTTYLogger sharedInstance] setForegroundColor:green backgroundColor:nil forFlag:LOG_FLAG_INFO];
}

@end
