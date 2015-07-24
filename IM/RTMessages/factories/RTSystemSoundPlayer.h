//
//  RTSystemSoundPlayer.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/13.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kRTSystemSoundTypeCAF;

FOUNDATION_EXPORT NSString * const kJRTSystemSoundTypeAIF;

FOUNDATION_EXPORT NSString * const kRTSystemSoundTypeAIFF;

FOUNDATION_EXPORT NSString * const kRTSystemSoundTypeWAV;

typedef void(^RTSystemSoundPlayerCompletionBlock)(void);

@interface RTSystemSoundPlayer : NSObject

@property (assign, nonatomic, readonly) BOOL on;

@property (strong, nonatomic) NSBundle *bundle;

+ (RTSystemSoundPlayer *)sharedPlayer;

- (void)toggleSoundPlayerOn:(BOOL)on;

- (void)playSoundWithFilename:(NSString *)filename fileExtension:(NSString *)fileExtension;

- (void)playSoundWithFilename:(NSString *)filename
                fileExtension:(NSString *)fileExtension
                   completion:(RTSystemSoundPlayerCompletionBlock)completionBlock;

- (void)playAlertSoundWithFilename:(NSString *)filename fileExtension:(NSString *)fileExtension;

- (void)playAlertSoundWithFilename:(NSString *)filename
                     fileExtension:(NSString *)fileExtension
                        completion:(RTSystemSoundPlayerCompletionBlock)completionBlock;

- (void)playVibrateSound;

- (void)stopAllSounds;

- (void)stopSoundWithFilename:(NSString *)filename;

- (void)preloadSoundWithFilename:(NSString *)filename fileExtension:(NSString *)fileExtension;

@end
