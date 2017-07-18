//
//  ChatMessageRecorderPanelView.h
//  testAudio
//
//  Created by 郭志伟 on 15-2-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatMessageRecorderPanelViewDelegate;

@interface ChatMessageRecorderPanelView : UIView

@property(nonatomic) UILabel *statusLbl;

- (void)setVolumeLevel:(CGFloat)level;
- (void)setVolumeStatusLblText:(NSString *)text;

@property(weak) id<ChatMessageRecorderPanelViewDelegate> delegate;

@end


@protocol ChatMessageRecorderPanelViewDelegate <NSObject>

- (void)ChatMessageRecorderPanelViewStart:(ChatMessageRecorderPanelView *)recorderPanelView;
- (void)ChatMessageRecorderPanelViewStop:(ChatMessageRecorderPanelView *)recorderPanelView;

@end