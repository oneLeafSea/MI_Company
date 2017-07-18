//
//  RTMessagesToolbarContentView.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RTMessagesComposerTextView.h"

FOUNDATION_EXPORT const CGFloat kRTMessagesToolbarContentViewHorizontalSpacingDefault;

@interface RTMessagesToolbarContentView : UIView

@property (weak, nonatomic, readonly) RTMessagesComposerTextView *textView;

@property (weak, nonatomic) UIButton *leftBarButtonItem;

@property (assign, nonatomic) CGFloat leftBarButtonItemWidth;

@property (weak, nonatomic, readonly) UIView *leftBarButtonContainerView;

@property (weak, nonatomic) UIButton *rightBarButtonItem;

@property (assign, nonatomic) CGFloat rightBarButtonItemWidth;

@property (weak, nonatomic, readonly) UIView *rightBarButtonContainerView;

@property (weak, nonatomic) UIButton *midBarButtonItem;

@property (assign, nonatomic) CGFloat midBarButtonItemWidth;

@property (weak, nonatomic, readonly) UIView *midBarButtonContainerView;

+ (UINib *)nib;


@end
