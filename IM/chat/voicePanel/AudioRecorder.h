//
//  AudioRecorder.h
//  testAudio
//
//  Created by 郭志伟 on 15-2-9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AudioRecorderDelegate;

@interface AudioRecorder : NSObject

+ (AudioRecorder *)shareRecorder;

- (void)recordWithPath:(NSString *)path duration:(NSTimeInterval) duration;

- (void)stop;

- (BOOL)deleteRecording;

@property(readonly) NSString* path;
@property(readonly) double    duration;

@property(weak) id<AudioRecorderDelegate> delegate;

@property(readonly, nonatomic) BOOL recording;

@end


@protocol AudioRecorderDelegate <NSObject>

- (void)AudioRecord:(AudioRecorder *)recorder started:(BOOL)started;

- (void)AudioRecord:(AudioRecorder *)recorder error:(NSError *)error;

- (void)AudioRecord:(AudioRecorder *)recorder recordingDuration:(NSTimeInterval)duration;

- (void)AudioRecord:(AudioRecorder *)recorder recordingLevel:(double)level;

- (void)AudioRecord:(AudioRecorder *)recorder end:(BOOL)stop;

@end
