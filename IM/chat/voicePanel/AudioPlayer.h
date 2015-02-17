//
//  AudioPlayer.h
//  testAudio
//
//  Created by 郭志伟 on 15-2-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AudioPlayerDelegate;

@interface AudioPlayer : NSObject

+ (AudioPlayer *)sharePlayer;

- (BOOL)playWithPath:(NSString *)path;

- (BOOL)playWithPath:(NSString *)path completion:(void(^)(BOOL finished))completion;

- (void)stop;

@property(weak) id<AudioPlayerDelegate> delegate;

@end


@protocol AudioPlayerDelegate <NSObject>

- (void)AudioPlayer:(AudioPlayer *)player playerDuration:(NSTimeInterval)duration;

- (void)AudioPlayer:(AudioPlayer *)player playerLevel:(double)level;

- (void)AudioPlayer:(AudioPlayer *)player end:(BOOL)suc;
@end