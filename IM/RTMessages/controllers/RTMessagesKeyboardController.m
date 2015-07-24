//
//  RTMessagesKeyboardController.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesKeyboardController.h"

#import "UIDevice+RTMessages.h"

NSString * const RTMessagesKeyboardControllerNotificationKeyboardDidChangeFrame = @"RTMessagesKeyboardControllerNotificationKeyboardDidChangeFrame";
NSString * const RTMessagesKeyboardControllerUserInfoKeyKeyboardDidChangeFrame = @"RTMessagesKeyboardControllerUserInfoKeyKeyboardDidChangeFrame";

static void * kRTMessagesKeyboardControllerKeyValueObservingContext = &kRTMessagesKeyboardControllerKeyValueObservingContext;

typedef void (^RTAnimationCompletionBlock)(BOOL finished);

@interface RTMessagesKeyboardController() <UIGestureRecognizerDelegate>

@property (assign, nonatomic) BOOL rt_isObserving;
@property (weak, nonatomic) UIView *keyboardView;

- (void)rt_registerForNotifications;
- (void)rt_unregisterForNotifications;

- (void)rt_didReceiveKeyboardDidShowNotification:(NSNotification *)notification;
- (void)rt_didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification;
- (void)rt_didReceiveKeyboardDidChangeFrameNotification:(NSNotification *)notification;
- (void)rt_didReceiveKeyboardDidHideNotification:(NSNotification *)notification;
- (void)rt_handleKeyboardNotification:(NSNotification *)notification completion:(RTAnimationCompletionBlock)completion;

- (void)rt_setKeyboardViewHidden:(BOOL)hidden;
- (void)rt_notifyKeyboardFrameNotificationForFrame:(CGRect)frame;
- (void)rt_resetKeyboardAndTextView;

- (void)rt_removeKeyboardFrameObserver;

- (void)rt_handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan;

@end

@implementation RTMessagesKeyboardController

#pragma mark - Initialization

- (instancetype)initWithTextView:(UITextView *)textView
                     contextView:(UIView *)contextView
                        delegate:(id<RTMessagesKeyboardControllerDelegate>)delegate {
    NSParameterAssert(textView != nil);
    NSParameterAssert(contextView != nil);
    
    self = [super init];
    if (self) {
        _textView = textView;
        _contextView = contextView;
        _delegate = delegate;
        _rt_isObserving = NO;
    }
    return self;
}

- (void)dealloc {
    [self rt_removeKeyboardFrameObserver];
    [self rt_unregisterForNotifications];
    _textView = nil;
    _contextView = nil;
    _delegate = nil;
    _keyboardView = nil;
}

#pragma mark - Setters
- (void)setKeyboardView:(UIView *)keyboardView {
    if (_keyboardView) {
        [self rt_removeKeyboardFrameObserver];
    }
}

#pragma mark - Getters

- (BOOL)keyboardIsVisible {
    return self.keyboardView != nil;
}

- (CGRect)currentKeyboardFrame {
    if (!self.keyboardIsVisible) {
        return CGRectNull;
    }
    
    return self.keyboardView.frame;
}

#pragma mark - Keyboard controller
- (void)beginListeningForKeyboard {
    if (self.textView.inputAccessoryView == nil) {
        self.textView.inputAccessoryView = [[UIView alloc] init];
    }
    
    [self rt_registerForNotifications];
}

- (void)endListeningForKeyboard {
    [self rt_unregisterForNotifications];
    
    [self rt_setKeyboardViewHidden:NO];
    self.keyboardView = nil;
}

#pragma mark - Notifications

- (void)rt_registerForNotifications {
    [self rt_unregisterForNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rt_didReceiveKeyboardDidShowNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rt_didReceiveKeyboardWillChangeFrameNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rt_didReceiveKeyboardDidChangeFrameNotification:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rt_didReceiveKeyboardDidHideNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)rt_unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)rt_didReceiveKeyboardDidShowNotification:(NSNotification *)notification {
    self.keyboardView = self.textView.inputAccessoryView.superview;
    [self rt_setKeyboardViewHidden:NO];
    
//    [self rt_handleKeyboardNotification:notification completion:^(BOOL finished) {
//        [self.panGestureRecognizer addTarget:self action:@selector(rt_handlePanGestureRecognizer:)];
//    }];
}

- (void)rt_didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification {
    [self rt_handleKeyboardNotification:notification completion:nil];
}

- (void)rt_didReceiveKeyboardDidChangeFrameNotification:(NSNotification *)notification {
    [self rt_setKeyboardViewHidden:NO];
    
    [self rt_handleKeyboardNotification:notification completion:nil];
}

- (void)rt_didReceiveKeyboardDidHideNotification:(NSNotification *)notification {
    self.keyboardView = nil;
    
//    [self rt_handleKeyboardNotification:notification completion:^(BOOL finished) {
//        [self.panGestureRecognizer removeTarget:self action:NULL];
//    }];
}

- (void)rt_handleKeyboardNotification:(NSNotification *)notification completion:(RTAnimationCompletionBlock)completion
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardEndFrameConverted = [self.contextView convertRect:keyboardEndFrame fromView:nil];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         [self rt_notifyKeyboardFrameNotificationForFrame:keyboardEndFrameConverted];
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

#pragma mark - Utilities

- (void)rt_setKeyboardViewHidden:(BOOL)hidden {
    self.keyboardView.hidden = hidden;
    self.keyboardView.userInteractionEnabled = !hidden;
}

- (void)rt_notifyKeyboardFrameNotificationForFrame:(CGRect)frame {
    [self.delegate keyboardController:self keyboardDidChangeFrame:frame];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RTMessagesKeyboardControllerNotificationKeyboardDidChangeFrame
                                                        object:self
                                                      userInfo:@{ RTMessagesKeyboardControllerUserInfoKeyKeyboardDidChangeFrame : [NSValue valueWithCGRect:frame] }];
}

- (void)rt_resetKeyboardAndTextView {
    [self rt_setKeyboardViewHidden:YES];
    [self rt_removeKeyboardFrameObserver];
    [self.textView resignFirstResponder];
}

#pragma mark - Key-value observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kRTMessagesKeyboardControllerKeyValueObservingContext) {
        
        if (object == self.keyboardView && [keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {
            
            CGRect oldKeyboardFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
            CGRect newKeyboardFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            
            if (CGRectEqualToRect(newKeyboardFrame, oldKeyboardFrame) || CGRectIsNull(newKeyboardFrame)) {
                return;
            }
            
            CGRect keyboardEndFrameConverted = [self.contextView convertRect:newKeyboardFrame
                                                                    fromView:self.keyboardView.superview];
            [self rt_notifyKeyboardFrameNotificationForFrame:keyboardEndFrameConverted];
        }
    }
}

- (void)rt_removeKeyboardFrameObserver {
    if (!_rt_isObserving) {
        return;
    }
    
    @try {
        [_keyboardView removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(frame))
                              context:kRTMessagesKeyboardControllerKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
    
    _rt_isObserving = NO;
}

#pragma mark - Pan gesture recognizer
- (void)rt_handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan
{
    CGPoint touch = [pan locationInView:self.contextView];
    
    //  system keyboard is added to a new UIWindow, need to operate in window coordinates
    //  also, keyboard always slides from bottom of screen, not the bottom of a view
    CGFloat contextViewWindowHeight = CGRectGetHeight(self.contextView.window.frame);
    
    if ([UIDevice rt_isCurrentDeviceBeforeiOS8]) {
        //  handle iOS 7 bug when rotating to landscape
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            contextViewWindowHeight = CGRectGetWidth(self.contextView.window.frame);
        }
    }
    
    CGFloat keyboardViewHeight = CGRectGetHeight(self.keyboardView.frame);
    
    CGFloat dragThresholdY = (contextViewWindowHeight - keyboardViewHeight - self.keyboardTriggerPoint.y);
    
    CGRect newKeyboardViewFrame = self.keyboardView.frame;
    
    BOOL userIsDraggingNearThresholdForDismissing = (touch.y > dragThresholdY);
    
    self.keyboardView.userInteractionEnabled = !userIsDraggingNearThresholdForDismissing;
    
    switch (pan.state) {
        case UIGestureRecognizerStateChanged:
        {
            newKeyboardViewFrame.origin.y = touch.y + self.keyboardTriggerPoint.y;
            
            //  bound frame between bottom of view and height of keyboard
            newKeyboardViewFrame.origin.y = MIN(newKeyboardViewFrame.origin.y, contextViewWindowHeight);
            newKeyboardViewFrame.origin.y = MAX(newKeyboardViewFrame.origin.y, contextViewWindowHeight - keyboardViewHeight);
            
            if (CGRectGetMinY(newKeyboardViewFrame) == CGRectGetMinY(self.keyboardView.frame)) {
                return;
            }
            
            [UIView animateWithDuration:0.0
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone
                             animations:^{
                                 self.keyboardView.frame = newKeyboardViewFrame;
                             }
                             completion:nil];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            BOOL keyboardViewIsHidden = (CGRectGetMinY(self.keyboardView.frame) >= contextViewWindowHeight);
            if (keyboardViewIsHidden) {
                [self rt_resetKeyboardAndTextView];
                return;
            }
            
            CGPoint velocity = [pan velocityInView:self.contextView];
            BOOL userIsScrollingDown = (velocity.y > 0.0f);
            BOOL shouldHide = (userIsScrollingDown && userIsDraggingNearThresholdForDismissing);
            
            newKeyboardViewFrame.origin.y = shouldHide ? contextViewWindowHeight : (contextViewWindowHeight - keyboardViewHeight);
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut
                             animations:^{
                                 self.keyboardView.frame = newKeyboardViewFrame;
                             }
                             completion:^(BOOL finished) {
                                 self.keyboardView.userInteractionEnabled = !shouldHide;
                                 
                                 if (shouldHide) {
                                     [self rt_resetKeyboardAndTextView];
                                 }
                             }];
        }
            break;
            
        default:
            break;
    }
}

@end
