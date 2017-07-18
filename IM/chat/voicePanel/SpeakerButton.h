//
//  SpeakerButton.h
//  testAudio
//
//  Created by 郭志伟 on 15-2-8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SpeakerButtonDelegate;

@interface SpeakerButton : UIButton

@property (weak) id<SpeakerButtonDelegate> delegate;

@end


@protocol SpeakerButtonDelegate <NSObject>

- (void)SpeakerButton:(SpeakerButton *)btn TouchDownAtParentPoint:(CGPoint)pt;
- (void)SpeakerButton:(SpeakerButton *)btn DragInsideAtParentPoint:(CGPoint)pt;
- (void)SpeakerButton:(SpeakerButton *)btn DragOutsideAtParentPoint:(CGPoint)pt;
- (void)SpeakerButton:(SpeakerButton *)btn TouchUpInsideAtParentPoint:(CGPoint)pt;
- (void)SpeakerButton:(SpeakerButton *)btn TouchUpOutsideAtparentPoint:(CGPoint)pt;

@end