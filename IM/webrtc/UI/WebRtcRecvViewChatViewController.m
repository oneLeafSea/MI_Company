//
//  WebRtcRecvViewChatViewController.m
//  IM
//
//  Created by 郭志伟 on 15-3-30.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "WebRtcRecvViewChatViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "RTCEAGLVideoView.h"
#import "UIImageView+common.h"
#import "AudioPlayer.h"
#import "WebRtcClient.h"
#import "utils.h"
#import "LogLevel.h"
#import "AppDelegate.h"
#import "WebRtcNotifyMsg.h"
#import "NSUUID+StringUUID.h"


@interface WebRtcRecvViewChatViewController () <WebRtcClientDelegate, RTCEAGLVideoViewDelegate> {
    NSTimer *m_timer;
    NSInteger m_timeStick;
    BOOL     m_remoteVideoEnable;
}

@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomContraint;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *hangupBtn;

@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIButton *switchBtn;

@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *remoteView;

@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UIView *avatarView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;

@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *localView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewBottomContaint;


@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIButton *rejectBtn;
@property (weak, nonatomic) IBOutlet UIButton *answerBtn;

@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;

@property (assign, nonatomic) CGSize localVideoSize;
@property (assign, nonatomic) CGSize remoteVideoSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewToTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewToBottomConstraint;


@property (strong, nonatomic) WebRtcClient *client;

@end

@implementation WebRtcRecvViewChatViewController

- (void)dealloc {
    DDLogInfo(@"WebRtcRecvViewChatViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    self.avatarImgView.image = [USER.avatarMgr getAvatarImageByUid:self.talkingUid];
    [self.avatarImgView circle];
    self.topView.hidden = YES;
    self.bottomView.hidden = YES;
    self.localView.hidden = YES;
    self.remoteView.delegate = self;
    self.localView.delegate = self;
    [[AudioPlayer sharePlayer] setNumberOfLoop:-1];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"answer" ofType:@"aif"];
    [[AudioPlayer sharePlayer] playWithPath:path];
    self.nameLbl.text = [APP_DELEGATE.user.rosterMgr getItemByUid:self.talkingUid].name;
    m_remoteVideoEnable = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [USER.msgMgr InsertVideoChatWithFrom:self.talkingUid fromName:self.nameLbl.text to:USER.uid msgId:[NSUUID uuid] connected:[self.client isConnected] interval:m_timeStick];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)videoBtnTapped:(id)sender {
    [self.localVideoTrack setEnabled:!self.localVideoTrack.isEnabled];
    [self.client sendVideoMsgWithEnable:self.localVideoTrack.isEnabled];
    self.localView.hidden = !self.localVideoTrack.isEnabled;
}

- (IBAction)switchBtnTapped:(id)sender {
    [self.client swichCamera];
}

- (IBAction)speakerBtnTapped:(UIButton *)sender {
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
    [self disconnect];
    [self dismissViewControllerAnimated:YES completion:^{
        [APP_DELEGATE.user.webRtcMgr setbusy:NO];
    }];
}

- (IBAction)rejectBtnTapped:(id)sender {
    WebRtcNotifyMsg *nm = [[WebRtcNotifyMsg alloc] initWithFrom:_uid to:_talkingUid rid:_rid];
    nm.contentType = @"reject";
    [USER.session post:nm];
    [[AudioPlayer sharePlayer] stop];
    [self dismissViewControllerAnimated:YES completion:^{
        [APP_DELEGATE.user.webRtcMgr setbusy:NO];
    }];
}

- (IBAction)answerBtnTapped:(id)sender {
    [[AudioPlayer sharePlayer] stop];
    [USER.webRtcMgr sendSignalWithType:@"handle" isSelf:YES roomId:self.rid];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleButtonContainer)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.avatarView.hidden = YES;
    self.answerView.hidden = YES;
    self.bgImgView.hidden = YES;
    self.topView.hidden = NO;
    self.bottomView.hidden = NO;
    m_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
    _client = [[WebRtcClient alloc] initWithDelegate:self roomServer:self.serverUrl iceUrl:USER.iceUrl token:USER.token key:USER.key iv:USER.iv uid:_uid invited:YES];
    [self.client joinRoomId:self.rid completion:^(BOOL finished) {
        if (!finished) {
            [Utils alertWithTip:@"对方已经取消。"];
            [m_timer invalidate];
            [self dismissViewControllerAnimated:YES completion:^{
                [USER.webRtcMgr setbusy:NO];
            }];

        }
    }];
    
}

- (void)handleTimer {
    m_timeStick++;
    self.timeLbl.text = [NSString stringWithFormat:@"%02ld:%02ld", m_timeStick / 60, m_timeStick % 60];
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
            
            self.bottomViewBottomContraint.constant = 8.0f;
            [self.bottomView setAlpha:1.0f];
        } else {
            [self.topViewTopConstraint setConstant:-40.0f];
            [self.topView setAlpha:0.0f];
            
            self.bottomViewBottomContraint.constant = -61.0f;
            [self.bottomView setAlpha:1.0f];
        }
        [self.view layoutIfNeeded];
    }];
}

- (void)remoteDisconnected {
    if (self.remoteVideoTrack) [self.remoteVideoTrack removeRenderer:self.remoteView];
    self.remoteVideoTrack = nil;
    [self.remoteView renderFrame:nil];
    [self videoView:self.localView didChangeVideoSize:self.localVideoSize];
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
            [self disconnect];
            [self dismissViewControllerAnimated:YES completion:^{
                [APP_DELEGATE.user.webRtcMgr setbusy:NO];
            }];
            break;
        case kWebRtcClientStateTimeout:
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
    [self setRemoteViewUIWithEnable:m_remoteVideoEnable];
    self.remoteVideoTrack = remoteVideoTrack;
    [self.remoteVideoTrack addRenderer:self.remoteView];

}

- (void)WebRtcClient:(WebRtcClient *)client
            didError:(NSError *)error {
    DDLogInfo(@"ERROR:%@", error);
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

- (void)layoutSubviews {
    CGRect bounds = self.remoteView.bounds;
    CGRect remoteVideoFrame =
    AVMakeRectWithAspectRatioInsideRect(_remoteVideoSize, bounds);
    CGFloat height = bounds.size.width * remoteVideoFrame.size.height / remoteVideoFrame.size.width;
    self.remoteViewToBottomConstraint.constant = (self.view.bounds.size.height - height)/2;
    self.remoteViewToTopConstraint.constant = (self.view.bounds.size.height - height)/2;
    [self.remoteView layoutSubviews];
}

#pragma mark - RTCEAGLVideoViewDelegate
- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [UIView animateWithDuration:0.4f animations:^{
        CGFloat containerWidth = self.view.frame.size.width;
        CGFloat containerHeight = self.view.frame.size.height;
        CGSize defaultAspectRatio = CGSizeMake(4, 3);
        if (videoView == self.localView) {
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
            [self layoutSubviews];
        } else if (videoView == self.remoteView) {
            //Resize Remote View
            self.remoteVideoSize = size;
            [self layoutSubviews];
        }
        //        [self.view layoutIfNeeded];
    }];
}

- (void)handleEnterBackground:(NSNotification *)notification {
//    [self disconnect];
//    [self dismissViewControllerAnimated:YES completion:^{
//        [APP_DELEGATE.user.webRtcMgr setbusy:NO];
//    }];
}
@end
