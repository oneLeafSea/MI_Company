//
//  RTMicButton.h
//  IM
//
//  Created by 郭志伟 on 15/7/14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTMicButtonDelegate;

@interface RTMicButton : UIButton

@property (weak) id<RTMicButtonDelegate> delegate;

@end

@protocol RTMicButtonDelegate <NSObject>

- (void)RTMicButton:(RTMicButton *)btn TouchDownAtParentPoint:(CGPoint)pt;
- (void)RTMicButton:(RTMicButton *)btn DragInsideAtParentPoint:(CGPoint)pt;
- (void)RTMicButton:(RTMicButton *)btn DragOutsideAtParentPoint:(CGPoint)pt;
- (void)RTMicButton:(RTMicButton *)btn TouchUpInsideAtParentPoint:(CGPoint)pt;
- (void)RTMicButton:(RTMicButton *)btn TouchUpOutsideAtparentPoint:(CGPoint)pt;

@end