//
//  ScaleableRoundView.m
//  testAudio
//
//  Created by 郭志伟 on 15-2-9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ScaleableRoundView.h"
#import <pop/POP.h>

@interface ScaleableRoundView() {
    UIImageView *m_backgrounImageView;
    UIImageView *m_centerImageView;
}
@end

@implementation ScaleableRoundView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    m_backgrounImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_circle"]];
    m_backgrounImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:m_backgrounImageView];
    [self setBgImgViewConstraints];
    
    m_centerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_listen"]];
    m_centerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:m_centerImageView];
    [self setCenterImgViewConstaints];
}

- (void)setBgImgViewConstraints {
    CGFloat ratio = 1.0;
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:m_backgrounImageView
                                      attribute:NSLayoutAttributeLeading
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self
                                      attribute:NSLayoutAttributeLeading
                                      multiplier:ratio
                                      constant:0];
    [self addConstraint:constraint];
    constraint = [NSLayoutConstraint
                  constraintWithItem:m_backgrounImageView
                  attribute:NSLayoutAttributeTrailing
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeTrailing
                  multiplier:ratio
                  constant:0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:m_backgrounImageView
                  attribute:NSLayoutAttributeTop
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeTop
                  multiplier:ratio
                  constant:0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:m_backgrounImageView
                  attribute:NSLayoutAttributeBottom
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeBottom
                  multiplier:ratio
                  constant:0];
    [self addConstraint:constraint];
}

- (void)setCenterImgViewConstaints {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:m_centerImageView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0];
    [self addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:m_centerImageView
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1
                                               constant:0];
    [self addConstraint:constraint];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    m_centerImageView.image = image;
}

- (void)setPressed:(BOOL)pressed {
    _pressed = pressed;
    m_backgrounImageView.image = [UIImage imageNamed:pressed ? @"chatmsg_play_enter" : @"chatmsg_circle"];
    
    
}

//- (void)setRatio:(CGFloat)ratio {
////    [self scaleToRatio:ratio];
//    CGFloat x = self.frame.origin.x - (self.frame.size.width - ratio * self.frame.size.width) / 2;
//    CGFloat y = self.frame.origin.y - (self.frame.size.height - ratio * self.frame.size.height) / 2;
//    CGFloat w = self.frame.size.width * ratio;
//    CGFloat h = self.frame.size.height * ratio;
//    
//    self.frame = CGRectMake(x, y, w, h);
//}

- (void)scaleToRatio:(CGFloat) ratio {
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(ratio, ratio)];
    [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleAnimation"];
}

@end
