//
//  RTMessagesKeyboardController.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class RTMessagesKeyboardController;

FOUNDATION_EXPORT NSString * const RTMessagesKeyboardControllerNotificationKeyboardDidChangeFrame;
FOUNDATION_EXPORT NSString * const RTMessagesKeyboardControllerUserInfoKeyKeyboardDidChangeFrame;

@protocol RTMessagesKeyboardControllerDelegate <NSObject>

@required
- (void)keyboardController:(RTMessagesKeyboardController *)keyboardController keyboardDidChangeFrame:(CGRect)keyboardFrame;

@end

@interface RTMessagesKeyboardController : NSObject

@property (weak, nonatomic) id<RTMessagesKeyboardControllerDelegate> delegate;

@property (weak, nonatomic, readonly) UITextView *textView;

@property (weak, nonatomic, readonly) UIView *contextView;


@property (assign, nonatomic) CGPoint keyboardTriggerPoint;

@property (assign, nonatomic, readonly) BOOL keyboardIsVisible;

@property (assign, nonatomic, readonly) CGRect currentKeyboardFrame;

- (instancetype)initWithTextView:(UITextView *)textView
                     contextView:(UIView *)contextView
                        delegate:(id<RTMessagesKeyboardControllerDelegate>)delegate;

- (void)beginListeningForKeyboard;

- (void)endListeningForKeyboard;

@end
