//
//  UIDevice+RTMessages.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/7.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "UIDevice+RTMessages.h"

@implementation UIDevice (RTMessages)

+ (BOOL)rt_isCurrentDeviceBeforeiOS8
{
    return [[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending;
}

@end
