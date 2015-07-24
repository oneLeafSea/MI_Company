//
//  RTScaleableRoundView.m
//  IM
//
//  Created by 郭志伟 on 15/7/14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTScaleableRoundView.h"
#import <pop/POP.h>

@interface RTScaleableRoundView() {
    UIImageView *_backgroundImageView;
    UIImageView *_centerImageView;
}
@end

@implementation RTScaleableRoundView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self rt_configureView];
    }
    return self;
}

- (void)awakeFromNib {
    [self rt_configureView];
}

- (void)rt_configureView {
    self.backgroundColor = [UIColor clearColor];
    _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_circle"]];
    _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_backgroundImageView];
    [self setBgImgViewConstraints];
    
    _centerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_listen"]];
    _centerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_centerImageView];
    [self setCenterImgViewConstaints];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _centerImageView.image = image;
}

- (void)setPressed:(BOOL)pressed {
    _pressed = pressed;
    _backgroundImageView.image = [UIImage imageNamed:pressed ? @"chatmsg_play_enter" : @"chatmsg_circle"];
    
    
}


- (void)scaleToRatio:(CGFloat) ratio {
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(ratio, ratio)];
    [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleAnimation"];
}

- (void)setBgImgViewConstraints {
    CGFloat ratio = 1.0;
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:_backgroundImageView
                                      attribute:NSLayoutAttributeLeading
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self
                                      attribute:NSLayoutAttributeLeading
                                      multiplier:ratio
                                      constant:0];
    [self addConstraint:constraint];
    constraint = [NSLayoutConstraint
                  constraintWithItem:_backgroundImageView
                  attribute:NSLayoutAttributeTrailing
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeTrailing
                  multiplier:ratio
                  constant:0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:_backgroundImageView
                  attribute:NSLayoutAttributeTop
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeTop
                  multiplier:ratio
                  constant:0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:_backgroundImageView
                  attribute:NSLayoutAttributeBottom
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeBottom
                  multiplier:ratio
                  constant:0];
    [self addConstraint:constraint];
}

- (void)setCenterImgViewConstaints {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_centerImageView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0];
    [self addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:_centerImageView
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1
                                               constant:0];
    [self addConstraint:constraint];
}

@end
