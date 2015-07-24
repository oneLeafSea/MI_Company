//
//  RTSystemSoundPlayer+RTMessages.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/13.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTSystemSoundPlayer.h"

#import "RTSystemSoundPlayer.h"

@interface RTSystemSoundPlayer (RTMessages)

+ (void)rt_playMessageReceivedSound;

+ (void)rt_playMessageReceivedAlert;

+ (void)rt_playMessageSentSound;

+ (void)rt_playMessageSentAlert;

@end
