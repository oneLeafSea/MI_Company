//
//  UIImage+RTMessages.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RTMessages)

- (UIImage *)rt_imageMaskedWithColor:(UIColor *)maskColor;

+ (UIImage *)rt_bubbleCompactImage;

+ (UIImage *)rt_defaultTypingIndicatorImage;

+ (UIImage *)rt_defaultAccessoryImage;

+ (UIImage *)rt_micImage;

+ (UIImage *)rt_emoteImage;

+ (UIImage *)rt_moreImage;

+ (UIImage *)rt_defaultPlayImage;

+ (UIImage *)rt_keyboardImage;

@end
