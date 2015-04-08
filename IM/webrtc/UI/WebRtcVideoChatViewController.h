//
//  WebRtcVideoChatViewController.h
//  IM
//
//  Created by 郭志伟 on 15-3-27.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppRTC/RTCEAGLVideoView.h>
#import "webrtcClient.h"


@interface WebRtcVideoChatViewController : UIViewController <RTCEAGLVideoViewDelegate, WebRtcClientDelegate>
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *remoteView;
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *localView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;

//Auto Layout Constraints used for animations
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerViewLeftConstraint;
- (IBAction)audioButtonPressed:(id)sender;
- (IBAction)videoButtonPressed:(id)sender;
- (IBAction)hangupButtonPressed:(id)sender;

@property (strong, nonatomic) NSString *roomUrl;
@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) WebRtcClient *client;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;
@property (assign, nonatomic) CGSize localVideoSize;
@property (assign, nonatomic) CGSize remoteVideoSize;
@property (assign, nonatomic) BOOL isZoom; //used for double tap remote view

@end
