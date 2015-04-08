//
//  AudioPlayer.m
//  testAudio
//
//  Created by 郭志伟 on 15-2-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayer() <AVAudioPlayerDelegate> {
    AVAudioPlayer *m_player;
    NSTimer       *m_timer;
    NSTimer       *m_levelTimer;
    double        m_counter;
    void (^m_completion)(BOOL);
    NSUInteger    m_numberOfLoops;
}
@end

@implementation AudioPlayer

+ (AudioPlayer *)sharePlayer {
    static AudioPlayer *sharePlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePlayer = [[self alloc] init];
        sharePlayer->m_numberOfLoops = 1;
    });
    return sharePlayer;
}

- (BOOL)playWithPath:(NSString *)path {
    NSError *err = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
//    [[AVAudioSession sharedInstance] setCategory :AVAudioSessionCategoryAmbient error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    m_player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&err];
    m_player.meteringEnabled = YES;
    m_player.delegate = self;
    m_counter = 0;
    m_timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(timeout) userInfo:nil repeats:YES];
    
    m_levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(levelTimeout) userInfo:nil repeats:YES];
    
    BOOL ret = NO;
    if ([m_player prepareToPlay]) {
        m_player.numberOfLoops = m_numberOfLoops;
        ret = [m_player play];
    }
    return ret;
}

- (void)setNumberOfLoop:(NSUInteger)loops {
    m_numberOfLoops = loops;
}

- (BOOL)playWithPath:(NSString *)path completion:(void(^)(BOOL finished))completion {
    m_completion = completion;
    return [self playWithPath:path];
}


- (void)stop {
    [m_timer invalidate];
    [m_levelTimer invalidate];
    [m_player stop];
    if (m_completion) {
        m_completion(NO);
        m_completion = nil;
    }
}

- (void)timeout {
    m_counter += 0.2f;
    if ([self.delegate respondsToSelector:@selector(AudioPlayer:playerDuration:)]) {
        [self.delegate AudioPlayer:self playerDuration:m_counter];
    }
}

- (void)levelTimeout {
    [m_player updateMeters];
    double peakPower = pow(10, (0.1 * [m_player peakPowerForChannel:0]));
    if ([self.delegate respondsToSelector:@selector(AudioPlayer:playerLevel:)]) {
        [self.delegate AudioPlayer:self playerLevel:peakPower];
    }
}

- (CGFloat)meterLevel:(CGFloat)power {
    float level;
    float minDecibels = -80.0f;
    float decibels = power;
    if (decibels < minDecibels) {
        level = 0.0f;
    } else if (decibels >= 0.0f) {
        level = 1.0f;
    } else {
        float root = 2.0f;
        float minAmp = powf(10.0f, 0.05f * minDecibels);
        float inverseAmpRange = 1.0f / (1.0f - minAmp);
        float amp = powf(10.0f, 0.05f * decibels);
        float adjAmp = (amp - minAmp) * inverseAmpRange;
        level = powf(adjAmp, 1.0f / root);
    }
    return level;
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    if ([self.delegate respondsToSelector:@selector(AudioPlayer:end:)]) {
        [self.delegate AudioPlayer:self end:flag];
    }
    [self stop];
    if (m_completion) {
        m_completion(flag);
        m_completion = nil;
    }
}


@end
