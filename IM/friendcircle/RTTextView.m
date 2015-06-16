//
//  RTTextView.m
//  IM
//
//  Created by 郭志伟 on 15/6/15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTTextView.h"

NSString * const RTTextViewContentSizeDidChangeNotification =      @"RTTextViewContentSizeDidChangeNotification";
NSString * const RTTextViewSelectedRangeDidChangeNotification =    @"RTTextViewSelectedRangeDidChangeNotification";

@interface RTTextView()

@property(nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic) BOOL didFlashScrollIndicators;
@end

@implementation RTTextView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self rt_commonInit];
    }
    return self;
}


- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self rt_commonInit];
    }
    return self;
}

- (void)rt_commonInit {
    self.font = [UIFont systemFontOfSize:14.0f];
    self.editable = YES;
    self.selectable = YES;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.directionalLockEnabled = YES;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rt_didBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rt_didChangeText:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rt_didEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
    
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
}

#pragma mark - UIView Overrides

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 34.0f);
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)layoutIfNeeded {
    return [super layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.placeholderLabel.hidden = [self rt_shouldHidePlaceholder];
    
    if (!self.placeholderLabel.hidden) {
        [UIView performWithoutAnimation:^{
            self.placeholderLabel.frame = [self rt_placeholderRectThatFits:self.bounds];
            [self sendSubviewToBack:self.placeholderLabel];
        }];
    }
}

#pragma mark - Getters
- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [UILabel new];
        _placeholderLabel.clipsToBounds = NO;
        _placeholderLabel.autoresizesSubviews = NO;
        _placeholderLabel.numberOfLines = 1;
        _placeholderLabel.font = self.font;
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.textColor = [UIColor lightGrayColor];
        _placeholderLabel.hidden = YES;
        
        [self addSubview:_placeholderLabel];
    }
    return _placeholderLabel;
}

- (NSString *)placeholder {
    return self.placeholderLabel.text;
}

- (UIColor *)placeholderColor {
    return self.placeholderLabel.textColor;
}

- (NSUInteger)numberOfLines {
    return fabs(self.contentSize.height / self.font.lineHeight);
}

- (NSUInteger)maxNumberOfLines {
    return _maxNumberOfLines;
}

- (BOOL)isExpanding {
    if (self.numberOfLines >= self.maxNumberOfLines) {
        return YES;
    }
    return NO;
}

- (BOOL)rt_shouldHidePlaceholder
{
    if (self.placeholder.length == 0 || self.text.length > 0) {
        return YES;
    }
    return NO;
}

- (CGRect)rt_placeholderRectThatFits:(CGRect)bounds
{
    CGRect rect = CGRectZero;
    rect.size = [self.placeholderLabel sizeThatFits:bounds.size];
    rect.origin = UIEdgeInsetsInsetRect(bounds, self.textContainerInset).origin;
    
    CGFloat padding = self.textContainer.lineFragmentPadding;
    rect.origin.x += padding;
    
    return rect;
}

#pragma mark - setter
- (void)setPlaceholder:(NSString *)placeholder {
    self.placeholderLabel.text = placeholder;
    [self setNeedsDisplay];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    self.placeholderLabel.textColor = placeholderColor;
}

- (void)setSelectedRange:(NSRange)selectedRange {
    [super setSelectedRange:selectedRange];
    [[NSNotificationCenter defaultCenter] postNotificationName:RTTextViewSelectedRangeDidChangeNotification object:nil];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.placeholderLabel.font = self.font;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    
    // Updates the placeholder text alignment too
    self.placeholderLabel.textAlignment = textAlignment;
}

#pragma mark - Notification Events
- (void)rt_didBeginEditing:(NSNotification *)notification {
    if (![notification.object isEqual:self]) {
        return;
    }
    // do something.
}


- (void)rt_didChangeText:(NSNotification *)notification {
    if (![notification.object isEqual:self]) {
        return;
    }
    if (self.placeholderLabel.hidden != [self rt_shouldHidePlaceholder]) {
        [self setNeedsLayout];
    }
}

- (void)rt_didEndEditing:(NSNotification *)notification {
    if (![notification.object isEqual:self]) {
        return;
    }
}


#pragma mark - KVO Listener
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:self] && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RTTextViewContentSizeDidChangeNotification object:self userInfo:nil];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Custom Actions
- (void)rt_flashScrollIndicatorsIfNeeded
{
    if (self.numberOfLines == self.maxNumberOfLines+1) {
        if (!_didFlashScrollIndicators) {
            _didFlashScrollIndicators = YES;
            [super flashScrollIndicators];
        }
    }
    else if (_didFlashScrollIndicators) {
        _didFlashScrollIndicators = NO;
    }
}


@end
