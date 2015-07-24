//
//  RTSystemSoundPlayer+RTMessages.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/13.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTSystemSoundPlayer+RTMessages.h"

#import "NSBundle+RTMessages.h"

static NSString * const kRTMessageReceivedSoundName = @"message_received";
static NSString * const kRTMessageSentSoundName = @"message_sent";

@implementation RTSystemSoundPlayer (RTMessages)

#pragma mark - Public

+ (void)rt_playMessageReceivedSound
{
    [self rt_playSoundFromJSQMessagesBundleWithName:kRTMessageReceivedSoundName asAlert:NO];
}

+ (void)rt_playMessageReceivedAlert
{
    [self rt_playSoundFromJSQMessagesBundleWithName:kRTMessageReceivedSoundName asAlert:YES];
}

+ (void)rt_playMessageSentSound
{
    [self rt_playSoundFromJSQMessagesBundleWithName:kRTMessageSentSoundName asAlert:NO];
}

+ (void)rt_playMessageSentAlert
{
    [self rt_playSoundFromJSQMessagesBundleWithName:kRTMessageSentSoundName asAlert:YES];
}


#pragma mark - Private

+ (void)rt_playSoundFromJSQMessagesBundleWithName:(NSString *)soundName asAlert:(BOOL)asAlert
{
    //  save sound player original bundle
    NSString *originalPlayerBundleIdentifier = [RTSystemSoundPlayer sharedPlayer].bundle.bundleIdentifier;
    
    //  search for sounds in this library's bundle
    [RTSystemSoundPlayer sharedPlayer].bundle = [NSBundle rt_messagesBundle];
    
    NSString *fileName = [NSString stringWithFormat:@"RTMessagesAssets.bundle/Sounds/%@", soundName];
    
    if (asAlert) {
        [[RTSystemSoundPlayer sharedPlayer] playAlertSoundWithFilename:fileName fileExtension:kRTSystemSoundTypeAIFF];
    }
    else {
        [[RTSystemSoundPlayer sharedPlayer] playSoundWithFilename:fileName fileExtension:kRTSystemSoundTypeAIFF];
    }
    
    //  restore original bundle
    [RTSystemSoundPlayer sharedPlayer].bundle = [NSBundle bundleWithIdentifier:originalPlayerBundleIdentifier];
}

@end
