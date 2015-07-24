//
//  RTRecorderView.h
//  IM
//
//  Created by 郭志伟 on 15/7/15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTRecorderViewDelegate;

@interface RTRecorderView : UIView

@property(nonatomic) UILabel *statusLbl;

- (void)setVolumeLevel:(CGFloat)level;
- (void)setVolumeStatusLblText:(NSString *)text;

@property(weak) id<RTRecorderViewDelegate> delegate;

@property(nonatomic, copy) NSString *audioDirectory;

@end

@protocol RTRecorderViewDelegate <NSObject>


- (void)RTRecorderView:(RTRecorderView *)recorderView audioPath:(NSString *)path duration:(CGFloat)duration;

@end