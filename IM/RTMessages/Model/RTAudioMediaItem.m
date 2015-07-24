//
//  RTAudioMediaItem.m
//  IM
//
//  Created by 郭志伟 on 15/7/20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTAudioMediaItem.h"
#import "RTAudioView.h"

#import "RTMessagesMediaViewBubbleImageMasker.h"
#import "AudioPlayer.h"

@interface RTAudioMediaItem()

@property(nonatomic, strong)RTAudioView *audioView;
@property(nonatomic, weak)AudioPlayer *audioPlayer;

@end

@implementation RTAudioMediaItem

- (instancetype)initWithMaskAsOutgoing:(BOOL)maskAsOutgoing {
    if (self = [super initWithMaskAsOutgoing:maskAsOutgoing]) {
        self.audioPlayer = [AudioPlayer sharePlayer];
    }
    return self;
}

- (UIView *)mediaView
{
    if (self.status == RTAudioMediaItemStatusRecving || self.status == RTAudioMediaItemStatusSending) {
        return nil;
    }
    self.audioView = [[RTAudioView alloc] initWithFrame:CGRectMake(0, 0, 100, 40.0f) isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    [self.audioView setTime:[NSString stringWithFormat:@"%ld", (long)_duration]];
    [RTMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:self.audioView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    self.audioView.playing = self.playing;
    return self.audioView;
}


- (void)setDuration:(CGFloat)duration {
    _duration = duration;
    [self.audioView setTime:[NSString stringWithFormat:@"%ld", (long)duration]];
}

- (CGSize)mediaViewDisplaySize
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return CGSizeMake(315.0f, 225.0f);
    }
    
    return CGSizeMake(100.0f, 40.0f);
}

- (UIView *)mediaPlaceholderView {
    return [super mediaPlaceholderView];
}

- (void)setPlaying:(BOOL)playing {
    if (self.status == RTAudioMediaItemtatusSent || self.status == RTAudioMediaItemStatusRecved) {
        _playing = playing;
        self.audioView.playing = playing;
        if (playing) {
            [self.audioPlayer playWithPath:self.audioUrl completion:^(BOOL finished) {
                _playing = NO;
                self.audioView.playing = NO;
            }];
        } else {
            [self.audioPlayer stop];
        }
        
    } else {
        _playing = NO;
        self.audioView.playing = playing;
    }
}


@end
