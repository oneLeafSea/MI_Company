//
//  AudioRecorder.m
//  testAudio
//
//  Created by 郭志伟 on 15-2-9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "AudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

static const NSTimeInterval kTimerInterval = 1;

@interface AudioRecorder() <AVAudioRecorderDelegate> {
    AVAudioRecorder *m_recorder;
    NSTimer *m_timer;
    NSTimer *m_levelTimer;
}
@end

@implementation AudioRecorder


+ (AudioRecorder *)shareRecorder {
    static AudioRecorder *shareRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareRecorder = [[self alloc] init];
    });
    return shareRecorder;
}

- (void)recordWithPath:(NSString *)path duration:(NSTimeInterval) duration {
    _path = [path copy];
    
    NSError *err= nil;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory :AVAudioSessionCategoryRecord error:nil];
    m_recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.path] settings:[self audioSetting] error:&err];
    m_recorder.delegate = self;
    m_recorder.meteringEnabled = YES;
    if (err) {
        if ([self.delegate respondsToSelector:@selector(AudioRecord:started:)]) {
            [self.delegate AudioRecord:self started:NO];
        }
        return;
    }
    BOOL ready = [m_recorder prepareToRecord];
    if (!ready) {
        if ([self.delegate respondsToSelector:@selector(AudioRecord:started:)]) {
            [self.delegate AudioRecord:self started:NO];
        }
        return;
    }
    if (![m_recorder recordForDuration:duration]) {
        if ([self.delegate respondsToSelector:@selector(AudioRecord:started:)]) {
            [self.delegate AudioRecord:self started:NO];
        }
        return;
    }
    if ([self.delegate respondsToSelector:@selector(AudioRecord:started:)]) {
        [self.delegate AudioRecord:self started:YES];
    }
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(timeout:) userInfo:nil repeats:YES];
    m_levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(levelTimer:) userInfo:nil repeats:YES];
}


- (void) timeout:(NSTimer *)timer {
    NSTimeInterval interval = m_recorder.currentTime;
    if ([self.delegate respondsToSelector:@selector(AudioRecord:recordingDuration:)]) {
        [self.delegate AudioRecord:self recordingDuration:interval];
    }
}

- (void)levelTimer:(NSTimer *)timer {
    [m_recorder updateMeters];
    double peakPower = pow(10, (0.1 * [m_recorder peakPowerForChannel:0]));
    if ([self.delegate respondsToSelector:@selector(AudioRecord:recordingLevel:)]) {
        [self.delegate AudioRecord:self recordingLevel:peakPower];
    }
}

- (void)stop {
    [m_levelTimer invalidate];
    [m_timer invalidate];
    _duration = m_recorder.currentTime;
    [m_recorder stop];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (BOOL)deleteRecording {
    return [m_recorder deleteRecording];
}

- (BOOL)recording {
    return m_recorder.recording;
}



#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if ([self.delegate respondsToSelector:@selector(AudioRecord:end:)]) {
        [self.delegate AudioRecord:self end:flag];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(AudioRecord:error:)]) {
        [self.delegate AudioRecord:self error:error];
    }
}

#pragma mark - private method

- (NSDictionary *)audioSetting {
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
                                    nil];
    return recordSettings;
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

@end
