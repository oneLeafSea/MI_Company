//
//  ChatMessageVolumePanelView.m
//  testAudio
//
//  Created by 郭志伟 on 15-2-10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageVolumePanelView.h"

@interface ChatMessageVolumePanelView() {
    UIImageView *m_leftBgImgView;
    UIImageView *m_leftFillImgView;
    UIImageView *m_leftMaskImgView;
    
    UIImageView *m_rightBgImgView;
    UIImageView *m_rightFillImgView;
    UIImageView *m_rightMaskImgView;
    
    NSLayoutConstraint *m_leftFillImgViewWidthConstraint;
    NSLayoutConstraint *m_RightFillImgViewWidthConstraint;
}

@end

@implementation ChatMessageVolumePanelView

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    m_leftBgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_volume_bg_left"]];
    m_leftFillImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_volume_fill_left"]];
    m_leftMaskImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_volume_mask_left"]];
    
    m_leftMaskImgView.translatesAutoresizingMaskIntoConstraints = NO;
    m_leftFillImgView.translatesAutoresizingMaskIntoConstraints = NO;
    m_leftMaskImgView.translatesAutoresizingMaskIntoConstraints = NO;
    
    m_rightBgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_volume_bg_right"]];
    m_rightFillImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_volume_fill_right"]];
    m_rightMaskImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_volume_mask_right"]];
    
    m_rightBgImgView.translatesAutoresizingMaskIntoConstraints = NO;
    m_rightFillImgView.translatesAutoresizingMaskIntoConstraints = NO;
    m_rightMaskImgView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.timeLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLbl.text = @"00:00";
    self.timeLbl.font = [UIFont systemFontOfSize:15.0f];
    self.timeLbl.textColor = [UIColor colorWithRed:105/255.0f green:105/255.0f blue:105/255.0f alpha:1.0f];
    self.timeLbl.textAlignment = NSTextAlignmentCenter;
    self.timeLbl.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:m_leftBgImgView];
    [self addSubview:m_leftFillImgView];
    [self addSubview:m_leftMaskImgView];
    
    [self addSubview:m_rightBgImgView];
    [self addSubview:m_rightFillImgView];
    [self addSubview:m_rightMaskImgView];
    [self addSubview:self.timeLbl];
    
    [self setupConstraints];
}

- (void)setupConstraints {
//    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(view, toolBar);
    
    // set time label.
    NSLayoutConstraint *xConstraint = [NSLayoutConstraint constraintWithItem:self.timeLbl
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0];
    [self addConstraint:xConstraint];
    NSLayoutConstraint *yContraint = [NSLayoutConstraint constraintWithItem:self.timeLbl
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0];
    [self addConstraint:yContraint];
    
    
    // set m_leftBgImgView, _timeLbl, m_rightBgImgView relation.
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(m_leftBgImgView, _timeLbl, m_rightBgImgView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[m_leftBgImgView][_timeLbl][m_rightBgImgView]|" options:0 metrics:nil views:viewsDictionary]];
    
    // height equal parent view.
    [self addTopAndBotomConstraintsWithView:m_leftBgImgView];
    [self addTopAndBotomConstraintsWithView:m_leftFillImgView];
    [self addTopAndBotomConstraintsWithView:m_leftMaskImgView];
   
    [self addTopAndBotomConstraintsWithView:m_rightBgImgView];
    [self addTopAndBotomConstraintsWithView:m_rightFillImgView];
    [self addTopAndBotomConstraintsWithView:m_rightMaskImgView];
    
    // add left right fill image view constraints.
    m_leftFillImgViewWidthConstraint = [NSLayoutConstraint constraintWithItem:m_leftFillImgView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1 constant:0];
    
    m_RightFillImgViewWidthConstraint = [NSLayoutConstraint constraintWithItem:m_rightFillImgView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1 constant:0];
    [self addConstraint:m_leftFillImgViewWidthConstraint];
    [self addConstraint:m_RightFillImgViewWidthConstraint];
    
    
    viewsDictionary = NSDictionaryOfVariableBindings(m_leftFillImgView, _timeLbl);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[m_leftFillImgView][_timeLbl]" options:0 metrics:nil views:viewsDictionary]];
    
    viewsDictionary = NSDictionaryOfVariableBindings(m_rightFillImgView, _timeLbl);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_timeLbl][m_rightFillImgView]" options:0 metrics:nil views:viewsDictionary]];
    
    // add left right mask image view constraints.
    [self addSzEqualConstraintsWithView:m_leftBgImgView otherView:m_leftMaskImgView];
    [self addSzEqualConstraintsWithView:m_rightBgImgView otherView:m_rightMaskImgView];
    
    
}

- (void)addTopAndBotomConstraintsWithView:(UIView *)view {
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(view);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:viewsDictionary]];
}

- (void)addSzEqualConstraintsWithView:(UIView *)view otherView:(UIView *)otherView {
    
    NSLayoutConstraint *leftMaskImgViewContraint = [NSLayoutConstraint constraintWithItem:view
                                                                                attribute:NSLayoutAttributeLeft
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:otherView
                                                                                attribute:NSLayoutAttributeLeft
                                                                               multiplier:1 constant:0];
    
    NSLayoutConstraint *rightMaskImgViewContraint = [NSLayoutConstraint constraintWithItem:view
                                                                                 attribute:NSLayoutAttributeRight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:otherView
                                                                                 attribute:NSLayoutAttributeRight
                                                                                multiplier:1 constant:0];
    NSLayoutConstraint *topMaskImgViewContraint = [NSLayoutConstraint constraintWithItem:view
                                                                                 attribute:NSLayoutAttributeTop
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:otherView
                                                                                 attribute:NSLayoutAttributeTop
                                                                                multiplier:1 constant:0];
    NSLayoutConstraint *bottomMaskImgViewContraint = [NSLayoutConstraint constraintWithItem:view
                                                                               attribute:NSLayoutAttributeBottom
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:otherView
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1 constant:0];
    [self addConstraint:leftMaskImgViewContraint];
    [self addConstraint:rightMaskImgViewContraint];
    [self addConstraint:topMaskImgViewContraint];
    [self addConstraint:bottomMaskImgViewContraint];

}

- (void)setRatio:(CGFloat)ratio {
    if (ratio > 1) {
        ratio = 1;
    }
    m_RightFillImgViewWidthConstraint.constant = m_rightBgImgView.frame.size.width * ratio;
    m_leftFillImgViewWidthConstraint.constant = m_leftBgImgView.frame.size.width * ratio;
    [self layoutIfNeeded];
}


@end
