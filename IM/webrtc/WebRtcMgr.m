//
//  WebRtcMgr.m
//  IM
//
//  Created by 郭志伟 on 15-3-26.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "WebRtcMgr.h"
#import "WebRtcNotifyMsg.h"
#import "WebRtcClient.h"
#import "NSUUID+StringUUID.h"
#import "WebRtcRecvViewChatViewController.h"
#import "WebRtcCallViewController.h"
#import "AppDelegate.h"
#import "MultiCallViewController.h"
#import "AudioPlayer.h"

//static NSString *kWebrtcUrl = @"wss://10.22.1.117:8088/webrtc";

@interface WebRtcMgr()<UIAlertViewDelegate> {
    BOOL m_busy;
    NSString *m_roomId;
}
@end

@implementation WebRtcMgr

- (instancetype) initWithUid:(NSString *)uid {
    if (self = [super init]) {
        _uid = uid;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWebRtcNotifyMsgNotificaiton object:nil];
}

- (BOOL)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWebRtcNotification:) name:kWebRtcNotifyMsgNotificaiton object:nil];
    return YES;
}

- (void)inviteUid:(NSString *)uid  session:(Session *)s {
    m_busy = YES;
    __block NSString *webrtcUrl = USER.rssUrl;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebRtcCallViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WebRtcCallViewController"];
    vc.serverUrl = [NSURL URLWithString:webrtcUrl];
    vc.uid = self.uid;
    vc.talkingUid = uid;
    [APP_DELEGATE.window.rootViewController presentViewController:vc animated:YES completion:^{
    }];
}


- (void)handleWebRtcNotification:(NSNotification *)notification {
    __block NSString *webrtcUrl = USER.rssUrl;
    __block WebRtcNotifyMsg *msg = notification.object;
    if ([[msg.content objectForKey:@"type"] isEqualToString:@"busy"] || [[msg.content objectForKey:@"type"] isEqualToString:@"reject"] ||
        [[msg.content objectForKey:@"type"] isEqualToString:@"close"]) {
        return;
    }
    if (m_busy) {
        WebRtcNotifyMsg *ack = [[WebRtcNotifyMsg alloc] initWithFrom:_uid to:msg.from rid:msg.rid];
        ack.contentType = @"busy";
        [USER.session post:ack];
        return;
    }
    m_busy = YES;
    
    if ([[msg.content objectForKey:@"type"] isEqualToString:@"mulitivoice"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AudioPlayer sharePlayer] setNumberOfLoop:-1];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"answer" ofType:@"aif"];
            [[AudioPlayer sharePlayer] playWithPath:path];
            NSString *from = msg.from;
            RosterItem *ri = [USER getRosterInfoByUid:from];
            m_roomId = [msg.rid copy];
            NSString *tip = [NSString stringWithFormat:@"%@想和你多人通话！", ri.name];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"多人通话" message:tip delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"接听", nil];
            [av show];
        });
        return;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WebRtcRecvViewChatViewController *recvController =[sb instantiateViewControllerWithIdentifier:@"WebRtcRecvViewChatViewController"];
        recvController.rid = msg.rid;
        recvController.uid = self.uid;
        recvController.serverUrl = [NSURL URLWithString:webrtcUrl];
        recvController.talkingUid = msg.from;
        [APP_DELEGATE.window.rootViewController presentViewController:recvController animated:YES completion:^{
        }];
    });
    
}

- (void)setbusy:(BOOL)busy {
    m_busy = busy;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[AudioPlayer sharePlayer] stop];
    switch (buttonIndex) {
        case 1: {
            MultiCallViewController *vc = [[MultiCallViewController alloc] initWithNibName:@"MultiCallViewController" bundle:nil];
            vc.invited = YES;
            vc.roomId = [m_roomId copy];
            [APP_DELEGATE.window.rootViewController presentViewController:vc animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

@end
