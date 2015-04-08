//
//  UIImageView+common.m
//  IM
//
//  Created by 郭志伟 on 15-3-31.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "UIImageView+common.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIImageView (common)

- (void)circle {
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.masksToBounds = YES;
}


@end
