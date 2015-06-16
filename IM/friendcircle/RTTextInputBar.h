//
//  RTTextInputBar.h
//  IM
//
//  Created by 郭志伟 on 15/6/15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RTTextView.h"

@protocol RTTextInputBarDelegate;

@interface RTTextInputBar : UIToolbar

@property (nonatomic, readonly) UILabel *charCountLabel;
@property (nonatomic, strong, readwrite) UIColor *charCountLabelNormalColor;
@property (nonatomic, strong, readwrite) UIColor *charCountLabelWarningColor;

@property(nonatomic, strong) RTTextView *textView;
@property(nonatomic, strong) UIButton   *rightButton;
@property (nonatomic, strong) UIButton  *leftButton;

@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, readwrite) NSUInteger maxCharCount;
@property(weak) id<RTTextInputBarDelegate> rtDelegate;

+ (instancetype)showInView:(UIView *)view;

@end


@protocol RTTextInputBarDelegate <NSObject>

- (void)textInputBar:(RTTextInputBar *)inputBar didPressSendBtnWithText:(NSString *)txt;

@end