//
//  UIView+RTMessages.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RTMessages)

- (void)rt_pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute;

- (void)rt_pinAllEdgesOfSubview:(UIView *)subview;

@end
