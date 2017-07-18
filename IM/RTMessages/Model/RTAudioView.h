//
//  RTAudioView.h
//  IM
//
//  Created by 郭志伟 on 15/7/20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTAudioView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                   isOutgoing:(BOOL)isOutgoing;

- (void)setTime:(NSString *)time;

@property(nonatomic, assign)BOOL playing;

@end
