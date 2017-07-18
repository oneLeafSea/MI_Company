//
//  WebRtcVideoChatViewController.m
//  IM
//
//  Created by 郭志伟 on 15-3-27.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "WebRtcVideoChatViewController.h"

static NSString *kWebrtcUrl = @"wss://10.22.1.105:8088/webrtc";

@interface WebRtcVideoChatViewController ()

@end

@implementation WebRtcVideoChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.audioButton.layer setCornerRadius:20.0f];
    [self.videoButton.layer setCornerRadius:20.0f];
    [self.hangupButton.layer setCornerRadius:20.0f];
    
    //Add Tap to hide/show controls
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleButtonContainer)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.remoteView.delegate = self;
    self.localView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
//    [self disconnect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orientationChanged:(NSNotification *)notification{
    [self videoView:self.localView didChangeVideoSize:self.localVideoSize];
    [self videoView:self.remoteView didChangeVideoSize:self.remoteVideoSize];
}

- (void)toggleButtonContainer {
    [UIView animateWithDuration:0.3f animations:^{
        if (self.buttonContainerViewLeftConstraint.constant <= -40.0f) {
            [self.buttonContainerViewLeftConstraint setConstant:0.0f];
            [self.buttonContainerView setAlpha:1.0f];
        } else {
            [self.buttonContainerViewLeftConstraint setConstant:-40.0f];
            [self.buttonContainerView setAlpha:0.0f];
        }
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)audioButtonPressed:(id)sender {
}

- (IBAction)videoButtonPressed:(id)sender {
}

- (IBAction)hangupButtonPressed:(id)sender {
}


#pragma mark -WebRtcClientDelegate
- (void)WebRtcClient:(WebRtcClient *)client
      didChangeState:(WebRtcClientState)state {
    
}

- (void)WebRtcClient:(WebRtcClient *)client
didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
    
}

- (void)WebRtcClient:(WebRtcClient *)client
didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
    
}

- (void)WebRtcClient:(WebRtcClient *)client
            didError:(NSError *)error {
    
}

- (void)WebRtcClient:(WebRtcClient *)client videoEnabled:(BOOL)enable {
    
}

#pragma mark -RTCEAGLVideoViewDelegate
- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size {
}
@end
