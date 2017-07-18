//
//  UIImageView+common.h
//  IM
//
//  Created by 郭志伟 on 15-3-31.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (common)

- (void)circle;

- (void)rt_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)image;

- (void)rt_setImageWithURL:(NSURL *)url;

@end
