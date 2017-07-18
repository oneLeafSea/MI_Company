//
//  UIColor+RTMessages.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RTMessages)

- (UIColor *)rt_colorByDarkeningColorWithValue:(CGFloat)value;

+ (UIColor *)rt_messageBubbleLightGrayColor;

+ (UIColor *)rt_messageBubbleBlueColor;

+ (UIColor *)rt_messageBubbleGreenColor;

@end
