//
//  NSBundle+RTMessages.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "NSBundle+RTMessages.h"
#import "RTMessagesViewController.h"

@implementation NSBundle (RTMessages)

+ (NSBundle *)rt_messagesBundle
{
    return [NSBundle bundleForClass:[RTMessagesViewController class]];
}

+ (NSBundle *)rt_messagesAssetBundle
{
    NSString *bundleResourcePath = [NSBundle rt_messagesBundle].resourcePath;
    NSString *assetPath = [bundleResourcePath stringByAppendingPathComponent:@"RTMessagesAssets.bundle"];
    return [NSBundle bundleWithPath:assetPath];
}

+ (NSString *)rt_localizedStringForKey:(NSString *)key
{
    return NSLocalizedStringFromTableInBundle(key, @"RTMessages", [NSBundle rt_messagesAssetBundle], nil);
}

@end
