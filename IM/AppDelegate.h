//
//  AppDelegate.h
//  IM
//
//  Created by guozw on 14/11/24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Reachability.h"
#import "Relogin.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) User *user;

@property (strong, nonatomic) Reachability *reachability;

@property (strong, nonatomic) Relogin *relogin;

- (NSString *)appVersion;

- (void)changeRootViewController:(UIViewController*)viewController;

@end


#define APP_DELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])
#define USER (((AppDelegate*)[[UIApplication sharedApplication] delegate]).user)


