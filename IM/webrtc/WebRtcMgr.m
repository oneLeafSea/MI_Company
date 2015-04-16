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

//static NSString *kWebrtcUrl = @"wss://10.22.1.117:8088/webrtc";

@interface WebRtcMgr() {
    WebRtcClient *m_client;
    BOOL m_busy;
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
    if ([[msg.content objectForKey:@"type"] isEqualToString:@"busy"] || [[msg.content objectForKey:@"type"] isEqualToString:@"reject"]) {
        return;
    }
    if (m_busy) {
        WebRtcNotifyMsg *ack = [[WebRtcNotifyMsg alloc] initWithFrom:_uid to:msg.from rid:msg.rid];
        ack.contentType = @"busy";
        [USER.session post:ack];
        return;
    }
    m_busy = YES;
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


@end
