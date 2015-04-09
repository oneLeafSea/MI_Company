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


@interface WebRtcRecvViewChatViewController () <WebRtcClientDelegate, RTCEAGLVideoViewDelegate> {
    NSTimer *m_timer;
    NSInteger m_timeStick;
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


@property (strong, nonatomic) WebRtcClient *client;

@end

@implementation WebRtcRecvViewChatViewController

- (void)dealloc {
    DDLogInfo(@"WebRtcRecvViewChatViewController");
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
    [[AudioPlayer sharePlayer] setNumberOfLoop:-1];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"answer" ofType:@"aif"];
    [[AudioPlayer sharePlayer] playWithPath:path];
    self.nameLbl.text = [APP_DELEGATE.user.rosterMgr getItemByUid:self.talkingUid].name;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)videoBtnTapped:(id)sender {
    [self.localVideoTrack setEnabled:!self.localVideoTrack.isEnabled];
}

- (IBAction)switchBtnTapped:(id)sender {
    [self.client swichCamera];
}

- (IBAction)speakerBtnTapped:(UIButton *)sender {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
}

- (IBAction)muteBtnTapped:(id)sender {
    [self.client mute];
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
    self.timeLbl.text = [NSString stringWithFormat:@"%02d:%02d", m_timeStick / 60, m_timeStick % 60];
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
    }
}

- (void)WebRtcClient:(WebRtcClient *)client
didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
    self.localView.hidden = NO;
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
    
    self.remoteVideoTrack = remoteVideoTrack;
    [self.remoteVideoTrack addRenderer:self.remoteView];

}

- (void)WebRtcClient:(WebRtcClient *)client
            didError:(NSError *)error {
    
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
//            CGSize aspectRatio = CGSizeEqualToSize(size, CGSizeZero) ? defaultAspectRatio : size;
//            CGRect videoRect = self.view.bounds;
//            CGRect videoFrame = AVMakeRectWithAspectRatioInsideRect(aspectRatio, videoRect);
//            [self.remoteViewTopConstraint setConstant:containerHeight/2.0f - videoFrame.size.height/2.0f];
//            [self.remoteViewBottomConstraint setConstant:containerHeight/2.0f - videoFrame.size.height/2.0f];
//            [self.remoteViewLeftConstraint setConstant:containerWidth/2.0f - videoFrame.size.width/2.0f]; //center
//            [self.remoteViewRightConstraint setConstant:containerWidth/2.0f - videoFrame.size.width/2.0f]; //center
            
        }
        [self.view layoutIfNeeded];
    }];

}
@end
