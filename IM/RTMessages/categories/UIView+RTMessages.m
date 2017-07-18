//
//  UIView+RTMessages.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "UIView+RTMessages.h"

@implementation UIView (RTMessages)

- (void)rt_pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:attribute
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:subview
                                                     attribute:attribute
                                                    multiplier:1.0f constant:0.0f]];
}

- (void)rt_pinAllEdgesOfSubview:(UIView *)subview {
    [self rt_pinSubview:subview toEdge:NSLayoutAttributeTop];
    [self rt_pinSubview:subview toEdge:NSLayoutAttributeBottom];
    [self rt_pinSubview:subview toEdge:NSLayoutAttributeLeading];
    [self rt_pinSubview:subview toEdge:NSLayoutAttributeTrailing];
}

@end
