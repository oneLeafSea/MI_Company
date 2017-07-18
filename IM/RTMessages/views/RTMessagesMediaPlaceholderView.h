//
//  RTMessagesMediaPlaceholderView.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTMessagesMediaPlaceholderView : UIView

@property (nonatomic, weak, readonly) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, weak, readonly) UIImageView *imageView;

+ (instancetype)viewWithActivityIndicator;

+ (instancetype)viewWithAttachmentIcon;


- (instancetype)initWithFrame:(CGRect)frame
              backgroundColor:(UIColor *)backgroundColor
        activityIndicatorView:(UIActivityIndicatorView *)activityIndicatorView;

- (instancetype)initWithFrame:(CGRect)frame
              backgroundColor:(UIColor *)backgroundColor
                    imageView:(UIImageView *)imageView;

@end
