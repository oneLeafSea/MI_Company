//
//  ChatMessageVoicePanelViewController.m
//  testAudio
//
//  Created by 郭志伟 on 15-2-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageVoicePanelViewController.h"
#import "ChatMessageRecorderViewController.h"
#import "ChatMessageSpeakerPanelViewController.h"
#import "AudioRecorder.h"
#import "ChatMessagePlayerPanelView.h"
#import "AudioPlayer.h"

static NSString *kVoicePath = @"voice";

typedef NS_ENUM(UInt32, VoicePanelMode) {
    VoicePanelModeSpeaker,
    VoicePanelModeRecorder,
    VoicePanelModePlayer
};

@interface ChatMessageVoicePanelViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, ChatMessageRecorderPanelViewDelegate, ChatMessageSpeakerPanelViewDelegate, AudioRecorderDelegate, ChatMessagePlayerPanelViewDelegate, AudioPlayerDelegate> {
    UIPageViewController *m_pageViewController;
    
    ChatMessageSpeakerPanelViewController *m_speakerViewConstroller;
    ChatMessageRecorderViewController     *m_recorderViewConstroller;
    
    ChatMessagePlayerPanelView            *m_playerView;
    
    AudioRecorder   *m_recorder;
    AudioPlayer     *m_player;
    
    NSString        *m_voicePath;
    
    VoicePanelMode  m_voicePanelMode;
    BOOL            m_delete;
    
}

@end

@implementation ChatMessageVoicePanelViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    m_pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [self addChildViewController:m_pageViewController];
    m_pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:m_pageViewController.view];
    m_pageViewController.delegate = self;
    m_pageViewController.dataSource = self;
    m_speakerViewConstroller = [[ChatMessageSpeakerPanelViewController alloc] initWithNibName:@"ChatMessageSpeakerPanelViewController" bundle:nil];
    m_speakerViewConstroller.speakerPanelView.delegate = self;
    
    m_recorderViewConstroller = [[ChatMessageRecorderViewController alloc] initWithNibName:@"ChatMessageRecorderViewController" bundle:nil];
    m_recorderViewConstroller.recorderView.delegate = self;
    
    [m_pageViewController setViewControllers:@[m_speakerViewConstroller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    m_playerView = [[ChatMessagePlayerPanelView alloc] initWithFrame:CGRectZero];
    m_playerView.translatesAutoresizingMaskIntoConstraints = NO;
    m_playerView.delegate = self;
    [self.view addSubview:m_playerView];
    m_playerView.hidden = YES;
    
    [self setupConstraints];
    
    m_recorder = [[AudioRecorder alloc] init];
    m_recorder.delegate = self;
    m_voicePanelMode = VoicePanelModeSpeaker;
    
    m_player = [[AudioPlayer alloc] init];
    m_player.delegate = self;
    
}

- (void)setupConstraints {
    UIView *view = m_pageViewController.view;
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(view);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(230)]|" options:0 metrics:nil views:viewsDict]];
    
    viewsDict = NSDictionaryOfVariableBindings(m_playerView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[m_playerView]|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[m_playerView(230)]|" options:0 metrics:nil views:viewsDict]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)getVoicePath {
    NSUUID *uuid = [NSUUID UUID];
    m_voicePath = [[self.voiceDir stringByAppendingPathComponent:uuid.UUIDString] stringByAppendingString:@".m4a"];
    
}

- (void)setVoicePath:(NSString *)path {
    m_voicePath = [path copy];
}

- (NSString *)getText:(NSUInteger) interval {
    NSInteger minutes = interval / 60;
    NSInteger seconds = interval % 60;
    
    NSString *ret = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    return ret;
}

- (void) startRecord {
    [self getVoicePath];
    [m_recorder recordWithPath:m_voicePath duration:120];
}


#pragma mark - <UIPageViewControllerDataSource>
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if ([viewController isEqual:m_recorderViewConstroller]) {
        return m_speakerViewConstroller;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if ([viewController isEqual:m_speakerViewConstroller]) {
        return m_recorderViewConstroller;
    }
    return nil;
}

#pragma mark <ChatMessageRecorderPanelViewDelegate>
- (void)ChatMessageRecorderPanelViewStart:(ChatMessageRecorderPanelView *)recorderPanelView {
    m_voicePanelMode = VoicePanelModeRecorder;
    [self startRecord];
}

- (void)ChatMessageRecorderPanelViewStop:(ChatMessageRecorderPanelView *)recorderPanelView {
    [m_recorder stop];
    m_playerView.hidden = NO;
    [m_recorderViewConstroller.recorderView setVolumeStatusLblText:@"00:00"];
    [m_recorderViewConstroller.recorderView setVolumeLevel:0.0f];
    [m_playerView setVolumeStatusLblText:[self getText:m_recorder.duration]];

}

#pragma mark <ChatMessageSpeakerPanelViewDelegate>
- (void)ChatMessageSpeakerPanelSpeakOver:(ChatMessageSpeakerPanelView *) speakerPanel {
    [m_recorder stop];
}

- (void)ChatMessageSpeakerPanelDragInPlayerBtn:(ChatMessageSpeakerPanelView *)speakerPanel {
    m_voicePanelMode = VoicePanelModePlayer;
    [m_recorder stop];
    m_playerView.hidden = NO;
    [speakerPanel setVolumeStatusLblText:@"00:00"];
    [speakerPanel setVolumeLevel:0.0f];
    [m_playerView setVolumeStatusLblText:[self getText:m_recorder.duration]];
}

- (void)ChatMessageSpeakerPanelDragInTrashCanBtn:(ChatMessageSpeakerPanelView *)speakerPanel {
    [speakerPanel setVolumeStatusLblText:@"00:00"];
    [speakerPanel setVolumeLevel:0.0f];
    m_delete = YES;
    [m_recorder stop];
    [m_recorder deleteRecording];
}

- (void)ChatMessageSpeakerPanelSpeakerBtnPressDown:(ChatMessageSpeakerPanelView *)speakerPanel {
    m_voicePanelMode = VoicePanelModeSpeaker;
    [self startRecord];
}


#pragma mark <AudioRecorderDelegate>
- (void)AudioRecord:(AudioRecorder *)recorder started:(BOOL)started {
    NSLog(@"is started: %d", started);
    if (!started) {
        if ([self.delegate respondsToSelector:@selector(ChatMessageVoicePanelViewController:recordFail:)]) {
            NSError *err = [NSError errorWithDomain:@"record" code:4100 userInfo:@{@"desp":@"启动录音失败！"}];
            [self.delegate ChatMessageVoicePanelViewController:self recordFail:err];
        }
    }
}

- (void)AudioRecord:(AudioRecorder *)recorder error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(ChatMessageVoicePanelViewController:recordFail:)]) {
        [self.delegate ChatMessageVoicePanelViewController:self recordFail:error];
    } //liekkas
}

- (void)AudioRecord:(AudioRecorder *)recorder recordingDuration:(NSTimeInterval)duration {
    if (m_voicePanelMode == VoicePanelModeSpeaker) {
        [m_speakerViewConstroller.speakerPanelView setVolumeStatusLblText:[self getText:duration]];
    }
    
    if (m_voicePanelMode == VoicePanelModeRecorder) {
        [m_recorderViewConstroller.recorderView setVolumeStatusLblText:[self getText:duration]];
    }
    
}

- (void)AudioRecord:(AudioRecorder *)recorder recordingLevel:(double)level {
    if (m_voicePanelMode == VoicePanelModeSpeaker) {
        [m_speakerViewConstroller.speakerPanelView setVolumeLevel:level];
    }
    
    if (m_voicePanelMode == VoicePanelModeRecorder) {
        [m_recorderViewConstroller.recorderView setVolumeLevel:level];
    }
}

- (void)AudioRecord:(AudioRecorder *)recorder end:(BOOL)stop {
    if (m_voicePanelMode == VoicePanelModeRecorder || m_voicePanelMode == VoicePanelModePlayer) {
        return;
    }
    if (m_voicePanelMode == VoicePanelModeSpeaker && m_delete) {
        m_delete = NO;
        return;
    }
    if (stop) {
        if ([self.delegate respondsToSelector:@selector(ChatMessageVoicePanelViewController:recordCompleteAtPath:duration:)]) {
            [self.delegate ChatMessageVoicePanelViewController:self recordCompleteAtPath:m_voicePath duration:m_recorder.duration];
        } else {
            if ([self.delegate respondsToSelector:@selector(ChatMessageVoicePanelViewController:recordFail:)]) {
                NSError *err = [NSError errorWithDomain:@"record" code:4100 userInfo:@{@"desp":@"录音结束失败！"}];
                [self.delegate ChatMessageVoicePanelViewController:self recordFail:err];
            }
        }
    }
}

#pragma mark <ChatMessagePlayerPanelViewDelegate>
- (void)ChatMessagePlayerPanelViewPlayerBtnPressed:(ChatMessagePlayerPanelView *)playerPanel stop:(BOOL)stop {
    if (stop) {
        [m_player stop];
    } else {
        [m_player playWithPath:m_voicePath];
    }
}

- (void)ChatMessagePlayerPanelViewSendBtnPressed:(ChatMessagePlayerPanelView *)playerPanel {
    m_playerView.hidden = YES;
    [m_player stop];
    if ([self.delegate respondsToSelector:@selector(ChatMessageVoicePanelViewController:recordCompleteAtPath:duration:)]) {
        [self.delegate ChatMessageVoicePanelViewController:self recordCompleteAtPath:m_voicePath duration:m_recorder.duration];
    }
}

- (void)ChatMessagePlayerPanelViewCancelBtnPressed:(ChatMessagePlayerPanelView *)playerPanel {
    [m_recorder deleteRecording];
    m_playerView.hidden = YES;
}

#pragma mark <AudioPlayerDelegate>
- (void)AudioPlayer:(AudioPlayer *)player playerDuration:(NSTimeInterval)duration {
    [m_playerView setVolumeStatusLblText:[self getText:duration]];
    m_playerView.progress = duration/m_recorder.duration;
}

- (void)AudioPlayer:(AudioPlayer *)player playerLevel:(double)level {
    [m_playerView setVolumeLevel:level];
}

- (void)AudioPlayer:(AudioPlayer *)player end:(BOOL)suc {
    m_playerView.progress = 0;
    m_playerView.stop = YES;
    
}


@end
