//
//  RTVoicePanelView.h
//  IM
//
//  Created by 郭志伟 on 15/7/15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTVoicePanelViewDelegate;

@interface RTVoicePanelView : UIView

@property(weak) id<RTVoicePanelViewDelegate> delegate;

@property(nonatomic, copy) NSString *audioDirectory;

@end

@protocol RTVoicePanelViewDelegate <NSObject>

- (void)RTVoicePanelView:(RTVoicePanelView *) speakerPanel audioPath:(NSString *)path duration:(CGFloat)duration;

@end
