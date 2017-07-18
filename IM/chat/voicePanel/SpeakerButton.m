//
//  SpeakerButton.m
//  testAudio
//
//  Created by 郭志伟 on 15-2-8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "SpeakerButton.h"
#import <pop/POP.h>

@interface SpeakerButton() {
}
@end

@implementation SpeakerButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void) setup {
    [self setBackgroundImage:[UIImage imageNamed:@"chatmsg_speaker"] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(handleDragOutside:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [self addTarget:self action:@selector(handleDragInside:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self addTarget:self action:@selector(handleTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(handleTouchUpInside:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(handleTouchUpOutside:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)handleDragOutside:(UIButton *)btn withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint pt = [touch locationInView:self.superview];
    if ([self.delegate respondsToSelector:@selector(SpeakerButton:DragOutsideAtParentPoint:)]) {
        [self.delegate SpeakerButton:self DragOutsideAtParentPoint:pt];
    }
}

     
- (void)handleDragInside:(UIButton *)btn withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint pt = [touch locationInView:self.superview];
    if ([self.delegate respondsToSelector:@selector(SpeakerButton:DragInsideAtParentPoint:)]) {
        [self.delegate SpeakerButton:self DragInsideAtParentPoint:pt];
    }
}

- (void)handleTouchDown:(UIButton *)btn withEvent:(UIEvent *)event {
    [self scaleToBig];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scaleToDefault];
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint pt = [touch locationInView:self.superview];
        if ([self.delegate respondsToSelector:@selector(SpeakerButton:TouchDownAtParentPoint:)]) {
            [self.delegate SpeakerButton:self TouchDownAtParentPoint:pt];
        }
    });
}

- (void)handleTouchUpOutside:(UIButton *)btn withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint pt = [touch locationInView:self.superview];
    if ([self.delegate respondsToSelector:@selector(SpeakerButton:TouchUpOutsideAtparentPoint:)]) {
        [self.delegate SpeakerButton:self TouchUpOutsideAtparentPoint:pt];
    }
}

- (void)handleTouchUpInside:(UIButton *)btn withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint pt = [touch locationInView:self.superview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(SpeakerButton:TouchUpInsideAtParentPoint:)]) {
            [self.delegate SpeakerButton:self TouchUpInsideAtParentPoint:pt];
        }
    });
}

#pragma mark - pop animation.

- (void)scaleToDefault
{
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleDefaultAnimation"];
}

- (void)scaleToBig {
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.2f, 1.2f)];
    [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSmallAnimation"];
}

@end
