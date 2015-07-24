//
//  RTMicPanelView.h
//  IM
//
//  Created by 郭志伟 on 15/7/14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTMicPanelViewDelegate;

@interface RTMicPanelView : UIView

@property(nonatomic, strong) UILabel *statusLbl;

@property(weak) id<RTMicPanelViewDelegate> delegate;


@property(nonatomic, copy) NSString *audioDirectory;


- (void)setVolumeLevel:(CGFloat)level;
- (void)setVolumeStatusLblText:(NSString *)text;

@end


@protocol RTMicPanelViewDelegate <NSObject>

- (void)RTMicPanelViewSpeakOver:(RTMicPanelView *) speakerPanel audioPath:(NSString *)path duration:(CGFloat)duration;

@end