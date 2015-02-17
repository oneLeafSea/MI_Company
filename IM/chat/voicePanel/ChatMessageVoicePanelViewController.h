//
//  ChatMessageVoicePanelViewController.h
//  testAudio
//
//  Created by 郭志伟 on 15-2-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatMessageVoicePanelViewControllerDelegate;

@interface ChatMessageVoicePanelViewController : UIViewController

@property(copy, nonatomic) NSString *voiceDir;
@property(weak) id<ChatMessageVoicePanelViewControllerDelegate> delegate;

@end


@protocol ChatMessageVoicePanelViewControllerDelegate <NSObject>

- (void)ChatMessageVoicePanelViewController:(ChatMessageVoicePanelViewController *)voicePanelVc recordCompleteAtPath:(NSString *)audioPath duration:(double)duration;


- (void)ChatMessageVoicePanelViewController:(ChatMessageVoicePanelViewController *)voicePanelVc recordFail:(NSError *)error;


@end