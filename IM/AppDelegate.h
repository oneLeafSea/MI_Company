//
//  AppDelegate.h
//  IM
//
//  Created by guozw on 14/11/24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IM.h"

#define MR_ENABLE_ACTIVE_RECORD_LOGGING 0

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, strong) IM *im;

@end

