//
//  ChatMessageSpeakerPanelView.h
//  testAudio
//
//  Created by 郭志伟 on 15-2-10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatMessageSpeakerPanelViewDelegate;

@interface ChatMessageSpeakerPanelView : UIView


@property(nonatomic, strong) UILabel *statusLbl;

@property(weak) id<ChatMessageSpeakerPanelViewDelegate> delegate;


- (void)setVolumeLevel:(CGFloat)level;
- (void)setVolumeStatusLblText:(NSString *)text;

@end


@protocol ChatMessageSpeakerPanelViewDelegate <NSObject>

- (void)ChatMessageSpeakerPanelSpeakOver:(ChatMessageSpeakerPanelView *) speakerPanel;

- (void)ChatMessageSpeakerPanelDragInPlayerBtn:(ChatMessageSpeakerPanelView *)speakerPanel;

- (void)ChatMessageSpeakerPanelDragInTrashCanBtn:(ChatMessageSpeakerPanelView *)speakerPanel;

- (void)ChatMessageSpeakerPanelSpeakerBtnPressDown:(ChatMessageSpeakerPanelView *)speakerPanel;

@end