//
//  ChatMessagePlayerPanelView.h
//  testAudio
//
//  Created by 郭志伟 on 15-2-11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatMessagePlayerPanelViewDelegate;

@interface ChatMessagePlayerPanelView : UIView

@property(weak) id<ChatMessagePlayerPanelViewDelegate> delegate;

@property(nonatomic) BOOL stop;
@property(nonatomic) double progress;


- (void)setVolumeLevel:(CGFloat)level;
- (void)setVolumeStatusLblText:(NSString *)text;

@end


@protocol ChatMessagePlayerPanelViewDelegate <NSObject>

- (void)ChatMessagePlayerPanelViewPlayerBtnPressed:(ChatMessagePlayerPanelView *)playerPanel stop:(BOOL)stop;
- (void)ChatMessagePlayerPanelViewSendBtnPressed:(ChatMessagePlayerPanelView *)playerPanel;
- (void)ChatMessagePlayerPanelViewCancelBtnPressed:(ChatMessagePlayerPanelView *)playerPanel;

@end