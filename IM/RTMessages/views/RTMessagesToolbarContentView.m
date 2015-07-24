//
//  RTMessagesToolbarContentView.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesToolbarContentView.h"
#import "UIView+RTMessages.h"

const CGFloat kRTMessagesToolbarContentViewHorizontalSpacingDefault = 8.0f;
@interface RTMessagesToolbarContentView()
@property (weak, nonatomic) IBOutlet RTMessagesComposerTextView *textView;
@property (weak, nonatomic) IBOutlet UIView *leftBarButtonContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBarButtonContainerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *rightBarButtonContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBarButtonContainerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftHorizontalSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightHorizontalSpacingConstraint;
@property (weak, nonatomic) IBOutlet UIView *midBarButtonContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *midBarButtonContainerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *midBarButtonRightSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *midBarButtonLeftSpacingConstraint;

@end

@implementation RTMessagesToolbarContentView

#pragma mark - Class methods

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([RTMessagesToolbarContentView class])
                          bundle:[NSBundle bundleForClass:[RTMessagesToolbarContentView class]]];
}


#pragma mark - Initialization

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.leftHorizontalSpacingConstraint.constant = kRTMessagesToolbarContentViewHorizontalSpacingDefault;
    self.rightHorizontalSpacingConstraint.constant = kRTMessagesToolbarContentViewHorizontalSpacingDefault;
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc
{
    _textView = nil;
    _leftBarButtonItem = nil;
    _rightBarButtonItem = nil;
    _midBarButtonItem = nil;
    _leftBarButtonContainerView = nil;
    _rightBarButtonContainerView = nil;
    _midBarButtonContainerView = nil;
}

#pragma mark - Setters
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.leftBarButtonContainerView.backgroundColor = backgroundColor;
    self.rightBarButtonContainerView.backgroundColor = backgroundColor;
    self.midBarButtonContainerView.backgroundColor = backgroundColor;
}

- (void)setLeftBarButtonItem:(UIButton *)leftBarButtonItem {
    if (_leftBarButtonItem) {
        [_leftBarButtonItem removeFromSuperview];
    }
    
    if (!leftBarButtonItem) {
        _leftBarButtonItem = nil;
        self.leftHorizontalSpacingConstraint.constant = 0.0f;
        self.leftBarButtonItemWidth = 0.0f;
        self.leftBarButtonContainerView.hidden = YES;
        return;
    }
    
    if (CGRectEqualToRect(leftBarButtonItem.frame, CGRectZero)) {
        leftBarButtonItem.frame = self.leftBarButtonContainerView.bounds;
    }
    
    self.leftBarButtonContainerView.hidden = NO;
    self.leftHorizontalSpacingConstraint.constant = kRTMessagesToolbarContentViewHorizontalSpacingDefault;
    self.leftBarButtonItemWidth = CGRectGetWidth(leftBarButtonItem.frame);
    
    [leftBarButtonItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.leftBarButtonContainerView addSubview:leftBarButtonItem];
    [self.leftBarButtonContainerView rt_pinAllEdgesOfSubview:leftBarButtonItem];
    [self setNeedsUpdateConstraints];
    
    _leftBarButtonItem = leftBarButtonItem;
}

- (void)setLeftBarButtonItemWidth:(CGFloat)leftBarButtonItemWidth {
    self.leftBarButtonContainerViewWidthConstraint.constant = leftBarButtonItemWidth;
    [self setNeedsUpdateConstraints];
}

- (void)setMidBarButtonItem:(UIButton *)midBarButtonItem {
    if (_midBarButtonItem) {
        [_midBarButtonItem removeFromSuperview];
    }
    
    if (!midBarButtonItem) {
        _midBarButtonItem = nil;
        self.midBarButtonLeftSpacingConstraint.constant = 0.0f;
        self.midBarButtonItemWidth = 0.0f;
        self.midBarButtonContainerView.hidden = YES;
        return;
    }
    
    if (CGRectEqualToRect(midBarButtonItem.frame, CGRectZero)) {
        midBarButtonItem.frame = self.midBarButtonContainerView.bounds;
    }
    
    self.midBarButtonContainerView.hidden = NO;
    self.midBarButtonLeftSpacingConstraint.constant = kRTMessagesToolbarContentViewHorizontalSpacingDefault;
    self.midBarButtonItemWidth = CGRectGetWidth(midBarButtonItem.frame);
    
    [midBarButtonItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.midBarButtonContainerView addSubview:midBarButtonItem];
    [self.midBarButtonContainerView rt_pinAllEdgesOfSubview:midBarButtonItem];
    [self setNeedsUpdateConstraints];
    
    _midBarButtonItem = midBarButtonItem;
}

- (void)setMidBarButtonItemWidth:(CGFloat)midBarButtonItemWidth {
    self.midBarButtonContainerViewWidthConstraint.constant = midBarButtonItemWidth;
    [self setNeedsUpdateConstraints];
}


- (void)setRightBarButtonItem:(UIButton *)rightBarButtonItem {
    if (_rightBarButtonItem) {
        [_rightBarButtonItem removeFromSuperview];
    }
    
    if (!rightBarButtonItem) {
        _rightBarButtonItem = nil;
        self.rightHorizontalSpacingConstraint.constant = 0.0f;
        self.rightBarButtonItemWidth = 0.0f;
        self.rightBarButtonContainerView.hidden = YES;
        return;
    }
    
    if (CGRectEqualToRect(rightBarButtonItem.frame, CGRectZero)) {
        rightBarButtonItem.frame = self.rightBarButtonContainerView.bounds;
    }
    
    self.rightBarButtonContainerView.hidden = NO;
    self.rightHorizontalSpacingConstraint.constant = kRTMessagesToolbarContentViewHorizontalSpacingDefault;
    self.rightBarButtonItemWidth = CGRectGetWidth(rightBarButtonItem.frame);
    
    [rightBarButtonItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.rightBarButtonContainerView addSubview:rightBarButtonItem];
    [self.rightBarButtonContainerView rt_pinAllEdgesOfSubview:rightBarButtonItem];
    [self setNeedsUpdateConstraints];
    
    _rightBarButtonItem = rightBarButtonItem;
}

- (void)setRightBarButtonItemWidth:(CGFloat)rightBarButtonItemWidth
{
    self.rightBarButtonContainerViewWidthConstraint.constant = rightBarButtonItemWidth;
    [self setNeedsUpdateConstraints];
}

#pragma mark - Getters

- (CGFloat)leftBarButtonItemWidth
{
    return self.leftBarButtonContainerViewWidthConstraint.constant;
}

- (CGFloat)rightBarButtonItemWidth
{
    return self.rightBarButtonContainerViewWidthConstraint.constant;
}

- (CGFloat)midBarButtonItemWidth {
    return self.midBarButtonContainerViewWidthConstraint.constant;
}

#pragma mark - UIView overrides

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [self.textView setNeedsDisplay];
}

@end
