//
//  RTMessagesAvatarImageFactory.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "RTMessagesAvatarImage.h"

@interface RTMessagesAvatarImageFactory : NSObject

+ (RTMessagesAvatarImage *)avatarImageWithPlaceholder:(UIImage *)placeholderImage diameter:(NSUInteger)diameter;

+ (RTMessagesAvatarImage *)avatarImageWithImage:(UIImage *)image diameter:(NSUInteger)diameter;

+ (UIImage *)circularAvatarImage:(UIImage *)image withDiameter:(NSUInteger)diameter;

+ (UIImage *)circularAvatarHighlightedImage:(UIImage *)image withDiameter:(NSUInteger)diameter;

+ (RTMessagesAvatarImage *)roundCornerAvatarImage:(UIImage *)image;

+ (RTMessagesAvatarImage *)avatarImageWithUserInitials:(NSString *)userInitials
                                        backgroundColor:(UIColor *)backgroundColor
                                              textColor:(UIColor *)textColor
                                                   font:(UIFont *)font
                                               diameter:(NSUInteger)diameter;

@end
