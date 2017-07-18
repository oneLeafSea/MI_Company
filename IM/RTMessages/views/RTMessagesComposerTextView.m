//
//  RTMessagesComposerTextView.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesComposerTextView.h"

#import <QuartzCore/QuartzCore.h>
#import "NSString+RTMessages.h"

@interface RTMessagesComposerTextView()

- (void)rt_configureTextView;

- (void)rt_addTextViewNotificationObservers;
- (void)rt_removeTextViewNotificationObservers;
- (void)rt_didReceiveTextViewNotification:(NSNotification *)notification;

- (NSDictionary *)rt_placeholderTextAttributes;

@end

@implementation RTMessagesComposerTextView

#pragma mark - Initialization

- (void)rt_configureTextView {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    CGFloat cornerRadius = 6.0f;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.cornerRadius = cornerRadius;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(cornerRadius, 0.0f, cornerRadius, 0.0f);
    
    self.textContainerInset = UIEdgeInsetsMake(4.0f, 2.0f, 4.0f, 2.0f);
    self.contentInset = UIEdgeInsetsMake(1.0f, 0.0f, 1.0f, 0.0f);
    
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    
    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor blackColor];
    self.textAlignment = NSTextAlignmentNatural;
    
    self.contentMode = UIViewContentModeRedraw;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    
    self.text = nil;
    
    _placeHolder = nil;
    _placeHolderTextColor = [UIColor lightGrayColor];
    
    [self rt_addTextViewNotificationObservers];
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self rt_configureTextView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self rt_configureTextView];
}

- (void)dealloc {
    [self rt_removeTextViewNotificationObservers];
    _placeHolder = nil;
    _placeHolderTextColor = nil;
}

#pragma mark - Composer text view
- (BOOL)hasText {
    return ([[self.text rt_stringByTrimingWhitespace] length] > 0);
}

#pragma mark - Setters

- (void)setPlaceHolder:(NSString *)placeHolder {
    if ([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    _placeHolder = [placeHolder copy];
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor {
    if ([placeHolderTextColor isEqual:_placeHolderTextColor]) {
        return;
    }
    
    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}

#pragma mark - UITextView overrides

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

#pragma mark - Notifications

- (void)rt_addTextViewNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rt_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rt_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rt_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
}

- (void)rt_removeTextViewNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:self];
}

- (void)rt_didReceiveTextViewNotification:(NSNotification *)notification {
    [self setNeedsDisplay];
}

#pragma mark - Utilities

- (NSDictionary *)rt_placeholderTextAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = self.textAlignment;
    
    return @{ NSFontAttributeName : self.font,
              NSForegroundColorAttributeName : self.placeHolderTextColor,
              NSParagraphStyleAttributeName : paragraphStyle };
}

@end
