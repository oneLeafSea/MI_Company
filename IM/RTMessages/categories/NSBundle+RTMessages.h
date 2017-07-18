//
//  NSBundle+RTMessages.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (RTMessages)

+ (NSBundle *)rt_messagesBundle;


+ (NSBundle *)rt_messagesAssetBundle;

+ (NSString *)rt_localizedStringForKey:(NSString *)key;

@end
