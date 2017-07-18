//
//  RTMessagesCellTextView.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesCellTextView.h"

@implementation RTMessagesCellTextView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textColor = [UIColor whiteColor];
    self.editable = NO;
    self.selectable = YES;
    self.userInteractionEnabled = YES;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.scrollEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.contentInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0;
    self.linkTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)
                                
                                 };
}

- (void)setSelectedRange:(NSRange)selectedRange {
    [super setSelectedRange:NSMakeRange(NSNotFound, 0)];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gestureRecognizer;
        if (tap.numberOfTapsRequired == 2) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //  ignore double-tap to prevent copy/define/etc. menu from showing
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gestureRecognizer;
        if (tap.numberOfTapsRequired == 2) {
            return NO;
        }
    }
    
    return YES;
}


@end
