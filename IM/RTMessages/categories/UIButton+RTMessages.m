//
//  UIButton+RTMessages.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/13.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "UIButton+RTMessages.h"
#import "UIImage+RTMessages.h"

@implementation UIButton (RTMessages)

- (void)setImage:(UIImage *)image {
    UIImage *accessoryImage = image;
    UIImage *normalImage = [accessoryImage rt_imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlightedImage = [accessoryImage rt_imageMaskedWithColor:[UIColor darkGrayColor]];
    
    [self setImage:normalImage forState:UIControlStateNormal];
    [self setImage:highlightedImage forState:UIControlStateHighlighted];
    
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor lightGrayColor];
}

@end
