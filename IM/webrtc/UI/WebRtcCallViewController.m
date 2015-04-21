//
//  WebRtcCallViewController.m
//  IM
//
//  Created by 郭志伟 on 15-4-1.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "WebRtcCallViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "RTCEAGLVideoView.h"
#import "UIImageView+common.h"
#import "AudioPlayer.h"
#import "utils.h"
#import "RTCVideoTrack.h"
#import "WebRtcClient.h"
#import "NSUUID+StringUUID.h"
#import "WebRtcNotifyMsg.h"
#import "AppDelegate.h"
#import "LogLevel.h"
#import "WebRtcNotifyMsg.h"

@interface WebRtcCallViewController () <WebRtcClientDelegate, RTCEAGLVideoViewDelegate> {
    NSTimer *m_callTimer;
    NSInteger m_callTimerStick;
    NSTimer *m_timer;
    NSInteger m_timeStick;
    BOOL      m_remoteVideoEnable;
}
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *remoteView;
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *localView;

@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *avatarView;

@property (weak, nonatomic) IBOutlet UILabel *tipLbl;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *hangupBtn;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;

// constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewBottomContaint;

@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;

@property (assign, nonatomic) CGSize localVideoSize;
@property (assign, nonatomic) CGSize remoteVideoSize;

@property (strong, nonatomic) WebRtcClient *client;
@property (nonatomic, strong) NSString *rid;

@end

static NSUInteger kWebrtcTimeout = 30;

@implementation WebRtcCallViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWebRtcNotifyMsgNotificaiton object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    m_callTimerStick = 0;
    self.avatarImgView.image = [USER.avatarMgr getAvatarImageByUid:self.talkingUid];
    [self.avatarImgView circle];
    self.nameLbl.text = [APP_DELEGATE.user.rosterMgr getItemByUid:self.talkingUid].name;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleButtonContainer)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.client = [[WebRtcClient alloc] initWithDelegate:self roomServer:self.serverUrl iceUrl:USER.iceUrl token:USER.token key:USER.key iv:USER.iv uid:self.uid invited:NO];
    _rid = [NSUUID uuid];
    WebRtcNotifyMsg *msg = [[WebRtcNotifyMsg alloc] initWithFrom:_uid to:self.talkingUid rid:self.rid];
    [self.client createRoomWithId:_rid Completion:^(BOOL finished) {
        if (finished) {
            [USER.session post:msg];
//            self.bgImgView.hidden =YES;
//            self.avatarView.hidden = YES;
        } else {
            [self disconnect];
            [[AudioPlayer sharePlayer] stop];
            if (m_callTimer) {
                [m_callTimer invalidate];
                m_callTimer = nil;
            }
            [self dismissViewControllerAnimated:YES completion:^{
                [USER.webRtcMgr setbusy:NO];
                [Utils alertWithTip:@"连接信令服务器失败。"];
            }];
        }
    }];
    
    
    [[AudioPlayer sharePlayer] setNumberOfLoop:-1];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"call" ofType:@"aif"];
    [[AudioPlayer sharePlayer] playWithPath:path];
    
    m_callTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleCallTimeout) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMsg:) name:kWebRtcNotifyMsgNotificaiton object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.topViewTopConstraint setConstant:-40.0f];
    [self.topView setAlpha:0.0f];
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)disconnect {
    if (self.client) {
        if (self.localVideoTrack) [self.localVideoTrack removeRenderer:self.localView];
        if (self.remoteVideoTrack) [self.remoteVideoTrack removeRenderer:self.remoteView];
        self.localVideoTrack = nil;
        [self.localView renderFrame:nil];
        self.remoteVideoTrack = nil;
        [self.remoteView renderFrame:nil];
        [self.client disconnect];
    }
}

- (void)toggleButtonContainer {
    [UIView animateWithDuration:0.3f animations:^{
        if (self.topViewTopConstraint.constant <= -40.0f) {
            [self.topViewTopConstraint setConstant:0.0f];
            [self.topView setAlpha:1.0f];
            
            self.bottomViewBottomConstraint.constant = 8.0f;
            [self.bottomView setAlpha:1.0f];
        } else {
            [self.topViewTopConstraint setConstant:-40.0f];
            [self.topView setAlpha:0.0f];
            
            self.bottomViewBottomConstraint.constant = -61.0f;
            [self.bottomView setAlpha:1.0f];
        }
        [self.view layoutIfNeeded];
    }];
}

- (void)handleCallTimeout {
    m_callTimerStick++;
    self.timeLbl.text = [NSString stringWithFormat:@"%02d:%02d", m_callTimerStick / 60, m_callTimerStick % 60];
    if (m_callTimerStick > kWebrtcTimeout) {
        [m_callTimer invalidate];
        m_callTimer = nil;
        [[AudioPlayer sharePlayer] stop];
        [self disconnect];
        [self dismissViewControllerAnimated:YES completion:^{
            [Utils alertWithTip:@"对方无响应."];
            [APP_DELEGATE.user.webRtcMgr setbusy:NO];
        }];
        
    }
    
}
- (IBAction)videoBtnTapped:(id)sender {
    [self.localVideoTrack setEnabled:!self.localVideoTrack.isEnabled];
    [self.client sendVideoMsgWithEnable:self.localVideoTrack.isEnabled];
    self.localView.hidden = !self.localVideoTrack.isEnabled;
}

- (IBAction)switchBtnTapped:(id)sender {
    [self.client swichCamera];
}

- (IBAction)speakerBtnTapped:(id)sender {
    static BOOL speaker = NO;
    if (!speaker) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        speaker = YES;
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                               error:nil];
        speaker = NO;
    }
    [self.speakerBtn setImage:[UIImage imageNamed:speaker ? @"webrtc_speaker_sel" : @"webrtc_speaker"] forState:UIControlStateNormal];
}

- (IBAction)muteBtnTapped:(id)sender {
    [self.client mute];
    [self.muteBtn setImage:[UIImage imageNamed:[self.client isMute] ? @"webrtc_mute_sel" : @"webrtc_mute"] forState:UIControlStateNormal];
}

- (IBAction)hangupBtnTapped:(id)sender {
    [m_timer invalidate];
    m_timer = nil;
    [m_callTimer invalidate];
    m_callTimer = nil;
    [[AudioPlayer sharePlayer] stop];
    [self disconnect];
    [self dismissViewControllerAnimated:YES completion:^{
        [APP_DELEGATE.user.webRtcMgr setbusy:NO];
    }];
}

#pragma mark - WebRtcClientDelegate
- (void)WebRtcClient:(WebRtcClient *)client
      didChangeState:(WebRtcClientState)state {
    switch (state) {
        case kWebRtcClientStateConnected:
            DDLogInfo(@"Client connected.");
            break;
        case kWebRtcClientStateConnecting:
            DDLogInfo(@"Client connecting.");
            break;
        case kWebRtcClientStateDisconnected:
            DDLogInfo(@"Client disconnected.");
            break;
        case kWebRtcClientStateLeave:
            [m_timer invalidate];
            m_timer = nil;
            [self disconnect];
            [self dismissViewControllerAnimated:YES completion:^{
                [APP_DELEGATE.user.webRtcMgr setbusy:NO];
                [[AudioPlayer sharePlayer] stop];
            }];
            break;
    }
}

- (void)WebRtcClient:(WebRtcClient *)client
didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
    self.localView.hidden = !localVideoTrack.isEnabled;
    if (self.localVideoTrack) {
        [self.localVideoTrack removeRenderer:self.localView];
        self.localVideoTrack = nil;
        [self.localView renderFrame:nil];
    }
    self.localVideoTrack = localVideoTrack;
    [self.localVideoTrack addRenderer:self.localView];
}

- (void)WebRtcClient:(WebRtcClient *)client
didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
    if (m_callTimer) {
        [m_callTimer invalidate];
        m_callTimer = nil;
    }
    if (!m_timer) {
        m_timeStick = 0;
        m_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeLbl) userInfo:nil repeats:YES];
        
    }
    [[AudioPlayer sharePlayer] stop];
    self.tipLbl.hidden = YES;
    self.remoteVideoTrack = remoteVideoTrack;
    [self.remoteVideoTrack addRenderer:self.remoteView];
    self.remoteView.hidden = !m_remoteVideoEnable;
}

- (void)WebRtcClient:(WebRtcClient *)client
            didError:(NSError *)error {
    DDLogError(@"ERROR:%@", error);
}

- (void)WebRtcClient:(WebRtcClient *)client videoEnabled:(BOOL)enable {
    m_remoteVideoEnable = enable;
    [self setRemoteViewUIWithEnable:m_remoteVideoEnable];
}

- (void)setRemoteViewUIWithEnable:(BOOL) enable {
    if (m_remoteVideoEnable) {
        self.remoteView.hidden = NO;
        self.bgImgView.hidden = YES;
        self.avatarView.hidden = YES;
    } else {
        self.remoteView.hidden = YES;
        self.bgImgView.hidden = NO;
        self.avatarView.hidden = NO;
    }
}

- (void)updateTimeLbl {
    m_timeStick++;
    self.timeLbl.text = [NSString stringWithFormat:@"%02d:%02d", m_timeStick / 60, m_timeStick % 60];
}

#pragma mark - RTCEAGLVideoViewDelegate
- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [UIView animateWithDuration:0.4f animations:^{
        CGFloat containerWidth = self.view.frame.size.width;
        CGFloat containerHeight = self.view.frame.size.height;
        CGSize defaultAspectRatio = CGSizeMake(4, 3);
        if (videoView == self.localView) {
            //Resize the Local View depending if it is full screen or thumbnail
            self.localVideoSize = size;
            CGSize aspectRatio = CGSizeEqualToSize(size, CGSizeZero) ? defaultAspectRatio : size;
            CGRect videoRect = self.view.bounds;
            if (self.remoteVideoTrack) {
                videoRect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width/4.0f, self.view.frame.size.height/4.0f);
                if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
                    videoRect = CGRectMake(0.0f, 0.0f, self.view.frame.size.height/4.0f, self.view.frame.size.width/4.0f);
                }
            }
            CGRect videoFrame = AVMakeRectWithAspectRatioInsideRect(aspectRatio, videoRect);
            
            //Resize the localView accordingly
            [self.localViewWidthConstraint setConstant:videoFrame.size.width];
            [self.localViewHeightConstraint setConstant:videoFrame.size.height];
            if (self.remoteVideoTrack) {
                [self.localViewBottomContaint setConstant:28.0f]; //bottom right corner
                [self.localViewRightConstraint setConstant:28.0f];
            } else {
                [self.localViewBottomContaint setConstant:containerHeight/2.0f - videoFrame.size.height/2.0f]; //center
                [self.localViewRightConstraint setConstant:containerWidth/2.0f - videoFrame.size.width/2.0f]; //center
            }
        } else if (videoView == self.remoteView) {
            //Resize Remote View
            self.remoteVideoSize = size;
        }
        [self.view layoutIfNeeded];
    }];
    
}


- (void)handleMsg:(NSNotification *)notification {
    WebRtcNotifyMsg *m = notification.object;
    NSString *type = [m.content objectForKey:@"type"];
    NSString *rid = [m.content objectForKey:@"rid"];
    if ([_rid isEqualToString:rid]) {
        if ([type isEqualToString:@"reject"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_timer invalidate];
                m_timer = nil;
                [m_callTimer invalidate];
                m_callTimer = nil;
                [[AudioPlayer sharePlayer] stop];
                [self disconnect];
                [self dismissViewControllerAnimated:YES completion:^{
                    [Utils alertWithTip:@"对方拒绝视频。"];
                    [APP_DELEGATE.user.webRtcMgr setbusy:NO];
                }];
            });
        }
        
        if ([type isEqualToString:@"busy"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_timer invalidate];
                m_timer = nil;
                [m_callTimer invalidate];
                m_callTimer = nil;
                [[AudioPlayer sharePlayer] stop];
                [self disconnect];
                [self dismissViewControllerAnimated:YES completion:^{
                    [Utils alertWithTip:@"对方正在视频中。"];
                    [APP_DELEGATE.user.webRtcMgr setbusy:NO];
                }];
            });
        }
    }
}

@end
