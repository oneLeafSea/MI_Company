//
//  RTRecorderView.m
//  IM
//
//  Created by 郭志伟 on 15/7/15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTRecorderView.h"

#import "ChatMessageVolumePanelView.h"
#import "AudioPlayer.h"
#import "AudioRecorder.h"
#import "CircleView.h"
#import "NSUUID+StringUUID.h"

static const double kRecordBtnSz = 90.0f;
#define kStyleColor [UIColor colorWithRed:75/255.0f green:192/255.0f blue:209/255.0f alpha:1.0f]
static const double kPlayerBtnSz = 90.0f;

static const double kCancelBtnHeight = 40.0f;
static const double kSendBtnHeight = 40.0f;


@interface RTRecorderView()<AudioPlayerDelegate, AudioRecorderDelegate> {
    ChatMessageVolumePanelView *m_volumePanel;
    UIButton                   *m_recordBtn;
    BOOL                       m_stop;
    
    UIButton                   *m_playerBtn;
    CircleView                 *m_circleView;
    UIButton                   *m_cancelBtn;
    UIButton                   *m_sendBtn;
}

@property(nonatomic, weak) AudioPlayer *player;
@property(nonatomic, weak) AudioRecorder *recorder;

@property(nonatomic) BOOL stop;
@property(nonatomic) double progress;

@property(nonatomic, copy) NSString *audioPath;

@end

@implementation RTRecorderView

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}


- (void)setup {
    self.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    m_volumePanel = [[ChatMessageVolumePanelView alloc] initWithFrame:CGRectZero];
    m_volumePanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:m_volumePanel];
    m_stop = YES;
    _stop = YES;
    
    self.recorder = [AudioRecorder shareRecorder];
    self.player = [AudioPlayer sharePlayer];
    m_recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    m_recordBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [m_recordBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_record"] forState:UIControlStateNormal];
    [m_recordBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_record_press"] forState:UIControlStateHighlighted];
    [m_recordBtn addTarget:self action:@selector(recordBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:m_recordBtn];
    
    
    self.statusLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.statusLbl];
    
    m_circleView = [[CircleView alloc] initWithFrame:CGRectMake(0, 0, kPlayerBtnSz + 3, kPlayerBtnSz + 3)];
    m_circleView.translatesAutoresizingMaskIntoConstraints = NO;
    m_circleView.strokeColor = kStyleColor;
    m_circleView.hidden = YES;
    [self addSubview:m_circleView];
    
    
    m_playerBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [m_playerBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_play"] forState:UIControlStateNormal];
    [m_playerBtn addTarget:self action:@selector(playerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    m_playerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    m_playerBtn.hidden = YES;
    [self addSubview:m_playerBtn];
    
    m_cancelBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [m_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [m_cancelBtn setTitleColor:kStyleColor forState:UIControlStateNormal];
    [m_cancelBtn addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    m_cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    m_cancelBtn.hidden = YES;
    [self addSubview:m_cancelBtn];
    
    m_sendBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    m_sendBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [m_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [m_sendBtn setTitleColor:kStyleColor forState:UIControlStateNormal];
    [m_sendBtn addTarget:self action:@selector(sendBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    m_sendBtn.hidden = YES;
    [self addSubview:m_sendBtn];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    // set up volumeView.
    NSLayoutConstraint *volumeViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:m_volumePanel
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                  multiplier:1.0f
                                                                                    constant:0];
    [self addConstraint:volumeViewCenterXConstraint];
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(m_volumePanel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[m_volumePanel]" options:0 metrics:nil views:viewsDictionary]];
    
    NSLayoutConstraint *volumeViewHeight = [NSLayoutConstraint constraintWithItem:m_volumePanel
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1 constant:30.0f];
    [self addConstraint:volumeViewHeight];
    
    NSLayoutConstraint *volumeViewWidth = [NSLayoutConstraint constraintWithItem:m_volumePanel
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:159.0f];
    [self addConstraint:volumeViewWidth];
    
    NSLayoutConstraint *recordBtnCenterXConstraint = [NSLayoutConstraint constraintWithItem:m_recordBtn
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                 multiplier:1.0f
                                                                                   constant:0];
    [self addConstraint:recordBtnCenterXConstraint];
    
    
    // set status label
    NSLayoutConstraint *statusLblLeftConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:m_volumePanel
                                                                               attribute:NSLayoutAttributeLeft
                                                                              multiplier:1.0f
                                                                                constant:0];
    [self addConstraint:statusLblLeftConstraint];
    
    NSLayoutConstraint *statusLblTopConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:m_volumePanel
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0f
                                                                               constant:0];
    [self addConstraint:statusLblTopConstraint];
    
    NSLayoutConstraint *statusLblRightConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:m_volumePanel
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1.0f
                                                                                 constant:0];
    [self addConstraint:statusLblRightConstraint];
    
    NSLayoutConstraint *statusLblBottomConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:m_volumePanel
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:0];
    [self addConstraint:statusLblBottomConstraint];
    
    
    // set record btn.
    viewsDictionary = NSDictionaryOfVariableBindings(m_recordBtn, m_volumePanel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[m_volumePanel]-10-[m_recordBtn]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    NSLayoutConstraint *recordBtnHeightConstraint = [NSLayoutConstraint constraintWithItem:m_recordBtn
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0f
                                                                                  constant:kRecordBtnSz];
    [self addConstraint:recordBtnHeightConstraint];
    
    NSLayoutConstraint *recordBtnWidthConstaint = [NSLayoutConstraint constraintWithItem:m_recordBtn
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.0f
                                                                                constant:kRecordBtnSz];
    [self addConstraint:recordBtnWidthConstaint];
    
    NSLayoutConstraint *playerBtnCenterXConstraint = [NSLayoutConstraint constraintWithItem:m_playerBtn
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                 multiplier:1.0f
                                                                                   constant:0];
    [self addConstraint:playerBtnCenterXConstraint];
    
    viewsDictionary = NSDictionaryOfVariableBindings(m_playerBtn, m_volumePanel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[m_volumePanel]-10-[m_playerBtn]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    NSLayoutConstraint *playerBtnHeightConstraint = [NSLayoutConstraint constraintWithItem:m_playerBtn
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0f
                                                                                  constant:kPlayerBtnSz];
    [self addConstraint:playerBtnHeightConstraint];
    
    NSLayoutConstraint *playerBtnWidthConstaint = [NSLayoutConstraint constraintWithItem:m_playerBtn
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.0f
                                                                                constant:kPlayerBtnSz];
    [self addConstraint:playerBtnWidthConstaint];
    
    // set circle view.
    NSLayoutConstraint *circleViewTopViewConstrain = [NSLayoutConstraint constraintWithItem:m_circleView
                                                                                  attribute:NSLayoutAttributeTop
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:m_playerBtn
                                                                                  attribute:NSLayoutAttributeTop
                                                                                 multiplier:1.0f
                                                                                   constant:-1.0f];
    [self addConstraint:circleViewTopViewConstrain];
    
    NSLayoutConstraint *circleViewLeftConstrain = [NSLayoutConstraint constraintWithItem:m_circleView
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:m_playerBtn
                                                                               attribute:NSLayoutAttributeLeft
                                                                              multiplier:1.0f
                                                                                constant:-1.5];
    [self addConstraint:circleViewLeftConstrain];
    
    NSLayoutConstraint *circleViewRightConstraint = [NSLayoutConstraint constraintWithItem:m_circleView
                                                                                 attribute:NSLayoutAttributeRight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:m_playerBtn
                                                                                 attribute:NSLayoutAttributeRight
                                                                                multiplier:1.0
                                                                                  constant:0];
    [self addConstraint:circleViewRightConstraint];
    
    NSLayoutConstraint *circleViewBottomConstraint = [NSLayoutConstraint constraintWithItem:m_circleView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:m_playerBtn
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0f
                                                                                   constant:0];
    [self addConstraint:circleViewBottomConstraint];
    
    
    // set cancel btn.
    NSLayoutConstraint *cancelBtnLeftConstraint = [NSLayoutConstraint constraintWithItem:m_cancelBtn
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeLeft
                                                                              multiplier:1.0f
                                                                                constant:0];
    [self addConstraint:cancelBtnLeftConstraint];
    
    NSLayoutConstraint *cancelBtnRightConstraint = [NSLayoutConstraint constraintWithItem:m_cancelBtn
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterX
                                                                               multiplier:1.0f
                                                                                 constant:0];
    [self addConstraint:cancelBtnRightConstraint];
    
    NSLayoutConstraint *cancelBtnBottomConstraint = [NSLayoutConstraint constraintWithItem:m_cancelBtn
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:0];
    [self addConstraint:cancelBtnBottomConstraint];
    
    NSLayoutConstraint *cancelBtnHeightConstraint = [NSLayoutConstraint constraintWithItem:m_cancelBtn
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0f
                                                                                  constant:kCancelBtnHeight];
    [self addConstraint:cancelBtnHeightConstraint];
    
    
    // set send btn.
    NSLayoutConstraint *sendBtnLeftConstraint = [NSLayoutConstraint constraintWithItem:m_sendBtn
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1.0f
                                                                              constant:0];
    [self addConstraint:sendBtnLeftConstraint];
    
    NSLayoutConstraint *sendBtnRightConstraint = [NSLayoutConstraint constraintWithItem:m_sendBtn
                                                                              attribute:NSLayoutAttributeRight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeRight
                                                                             multiplier:1.0f
                                                                               constant:0];
    [self addConstraint:sendBtnRightConstraint];
    
    NSLayoutConstraint *sendBtnBottomConstraint = [NSLayoutConstraint constraintWithItem:m_sendBtn
                                                                               attribute:NSLayoutAttributeBottom
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1.0f
                                                                                constant:0];
    [self addConstraint:sendBtnBottomConstraint];
    
    NSLayoutConstraint *sendBtnHeightConstraint = [NSLayoutConstraint constraintWithItem:m_sendBtn
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.0f
                                                                                constant:kSendBtnHeight];
    [self addConstraint:sendBtnHeightConstraint];
}


- (void)recordBtnPressed:(UIButton *)btn {
    NSLog(@"record btn pressed");
    m_stop = !m_stop;
    if (m_stop) {
        
        [btn setBackgroundImage:[UIImage imageNamed:@"chatmsg_record"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"chatmsg_record_press"] forState:UIControlStateHighlighted];
        [self.recorder stop];
        
        if (self.recorder.duration < 0.6f) {
            return;
        }
        
        m_circleView.hidden = NO;
        m_playerBtn.hidden = NO;
        m_sendBtn.hidden = NO;
        m_cancelBtn.hidden = NO;
        
    } else {
        [m_recordBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_stop"] forState:UIControlStateNormal];
        [m_recordBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_stop_press"] forState:UIControlStateHighlighted];
        self.recorder.delegate = self;
        
        if (!self.audioDirectory) {
            self.audioDirectory = NSTemporaryDirectory();
        }
        
        NSString *fileName = [NSString stringWithFormat:@"%@.m4a", [NSUUID uuid]];
        self.audioPath = [self.audioDirectory stringByAppendingPathComponent:fileName];
        [self.recorder recordWithPath:self.audioPath duration:120];
    }
    
}


- (void)playerBtnPressed:(UIButton *)playerBtn {
    self.stop = !self.stop;
    if (!self.stop) {
        self.player.delegate = self;
        [self.player playWithPath:self.audioPath];
    } else {
        [self.player stop];
    }
}

- (void)cancelBtnPressed:(UIButton *)cancelBtn {
    m_cancelBtn.hidden = YES;
    m_sendBtn.hidden = YES;
    m_circleView.hidden = YES;
    m_playerBtn.hidden = YES;
    [self.recorder deleteRecording];
    self.stop = YES;
    [self setVolumeLevel:0.0f];
    [self setVolumeStatusLblText:@"00:00"];
}

- (void)sendBtnPressed:(UIButton *)sendBtn {
    m_cancelBtn.hidden = YES;
    m_sendBtn.hidden = YES;
    m_circleView.hidden = YES;
    m_playerBtn.hidden = YES;
    self.stop = YES;
    [self setVolumeLevel:0.0f];
    [self setVolumeStatusLblText:@"00:00"];
    
    if ([self.delegate respondsToSelector:@selector(RTRecorderView:audioPath:duration:)]) {
        [self.delegate RTRecorderView:self audioPath:self.audioPath duration:self.recorder.duration];
    }
}

- (void)setVolumeLevel:(CGFloat)level {
    m_volumePanel.ratio = level;
}

- (void)setVolumeStatusLblText:(NSString *)text {
    m_volumePanel.timeLbl.text = text;
}

- (void)setStop:(BOOL)stop {
    _stop = stop;
    [m_playerBtn setBackgroundImage:self.stop ? [UIImage imageNamed:@"chatmsg_play"] : [UIImage imageNamed:@"chatmsg_stop"] forState:UIControlStateNormal];
    [m_circleView setStrokeEnd:0 animated:NO];
}

- (void)setProgress:(double)progress {
    [m_circleView setStrokeEnd:progress animated:YES];
}

#pragma mark - audio recorder delegate

- (void)AudioRecord:(AudioRecorder *)recorder started:(BOOL)started {
    if (!started) {
        NSLog(@"recorder error on starting");
    }
}

- (void)AudioRecord:(AudioRecorder *)recorder error:(NSError *)error {
    if (error) {
        NSLog(@"recorder error.");
    }
}

- (void)AudioRecord:(AudioRecorder *)recorder recordingDuration:(NSTimeInterval)duration {
    [self setVolumeStatusLblText:[self getText:duration]];
}

- (void)AudioRecord:(AudioRecorder *)recorder recordingLevel:(double)level {
    [self setVolumeLevel:level];
}

- (void)AudioRecord:(AudioRecorder *)recorder end:(BOOL)stop {

}

- (NSString *)getText:(NSUInteger) interval {
    NSInteger minutes = interval / 60;
    NSInteger seconds = interval % 60;
    
    NSString *ret = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    return ret;
}


#pragma mark - audio player delegate.

- (void)AudioPlayer:(AudioPlayer *)player playerDuration:(NSTimeInterval)duration {
    [self setVolumeStatusLblText:[self getText:duration]];
    self.progress = duration/self.recorder.duration;
}

- (void)AudioPlayer:(AudioPlayer *)player playerLevel:(double)level {
    [self setVolumeLevel:level];
}

- (void)AudioPlayer:(AudioPlayer *)player end:(BOOL)suc {
    self.stop = YES;
}

@end
