//
//  RTMessagesLabel.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesLabel.h"

@interface RTMessagesLabel()

- (void)rt_configureLable;

@end

@implementation RTMessagesLabel

- (void)rt_configureLable {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.textInsets = UIEdgeInsetsZero;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self rt_configureLable];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self rt_configureLable];
}

- (void)setTextInsets:(UIEdgeInsets)textInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_textInsets, textInsets)) {
        return;
    }
    
    _textInsets = textInsets;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    [super drawTextInRect:CGRectMake(CGRectGetMinX(rect) + self.textInsets.left,
                                     CGRectGetMinY(rect) + self.textInsets.top,
                                     CGRectGetWidth(rect) - self.textInsets.right,
                                     CGRectGetHeight(rect) - self.textInsets.bottom)];
}

@end
