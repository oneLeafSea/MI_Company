//
//  AppDelegate.h
//  IM
//
//  Created by guozw on 14/11/24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) User *user;

@end


#define APP_DELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])
