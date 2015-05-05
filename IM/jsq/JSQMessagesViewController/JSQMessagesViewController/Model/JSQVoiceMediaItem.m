//
//  JSQVoiceMediaItem.m
//  IM
//
//  Created by 郭志伟 on 15-2-13.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "JSQVoiceMediaItem.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "JSQVoiceMediaOutgoingView.h"
#import "JSQVoiceMediaIncomingView.h"

@interface JSQVoiceMediaItem() {
    JSQVoiceMediaOutgoingView *m_outgoingView;
    JSQVoiceMediaIncomingView *m_incomingView;
}
@end

@implementation JSQVoiceMediaItem


- (instancetype)initWithFilePath:(NSString *)filePath
                         isReady:(BOOL)isReady
                        duration:(double) duration
                        outgoing:(BOOL)maskAsOutgoing
                           msgId:(NSString *)msgId{
    if (self = [super initWithMaskAsOutgoing:maskAsOutgoing]) {
        self.filePath = [filePath copy];
        self.isReady = isReady;
        _duration = duration;
        self.msgId = msgId;
    }
    return self;
}

- (UIView *)mediaView {
    if (!self.isReady) {
        return nil;
    }
    if (self.appliesMediaViewMaskAsOutgoing) {
        m_outgoingView = [[[NSBundle mainBundle] loadNibNamed:@"JSQVoiceMediaOutgoingView" owner:self options:nil] objectAtIndex:0];
        NSInteger d = self.duration;
        m_outgoingView.durationLbl.text = [NSString stringWithFormat:@"%ld''", (long)d];
        return m_outgoingView;
    }
    m_incomingView = [[[NSBundle mainBundle] loadNibNamed:@"JSQVoiceMediaIncomingView" owner:self options:nil] objectAtIndex:0];
    NSInteger d = self.duration;
    m_incomingView.durationLbl.text = [NSString stringWithFormat:@"%ld''", (long)d];
    return m_incomingView;
}

- (CGSize)mediaViewDisplaySize {
    return CGSizeMake(120, 38);
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    if (self.appliesMediaViewMaskAsOutgoing) {
        if (playing) {
            [m_outgoingView.speakerView startAnimating];
        } else {
            [m_outgoingView.speakerView stopAnimating];
        }
        
    } else {
        if (playing) {
            [m_incomingView.speakerImgView startAnimating];
        } else {
            [m_incomingView.speakerImgView stopAnimating];
        }
    }
}

- (NSUInteger)hash {
    return super.hash ^ self.filePath.hash;
}

@end
