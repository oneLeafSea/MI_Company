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
    NSString *m_roomId;
    UIAlertView *m_av;
    NSString *m_invitedId;
    NSString *m_talkingId;
}
@property (atomic) BOOL busy;

@property(nonatomic) UIViewController *recvVc;
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
    self.busy = YES;
    __block NSString *webrtcUrl = USER.rssUrl;
    m_talkingId = [uid copy];
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
    
    if ([[msg.content objectForKey:@"type"] isEqualToString:@"handle"] || [[msg.content objectForKey:@"type"] isEqualToString:@"close"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AudioPlayer sharePlayer] stop];
            if (m_av.visible) {
                [m_av dismissWithClickedButtonIndex:4 animated:YES];
            }
            if (self.recvVc) {
                [self.recvVc dismissViewControllerAnimated:YES completion:^{
                    self.recvVc = nil;
                }];
            }
            self.busy = NO;
        });
        return;
    }
    
    if (self.busy) {
        WebRtcNotifyMsg *ack = [[WebRtcNotifyMsg alloc] initWithFrom:_uid to:msg.from rid:msg.rid];
        ack.contentType = @"busy";
        [USER.session post:ack];
        return;
    }
    self.busy = YES;
    
  
    
    if ([[msg.content objectForKey:@"type"] isEqualToString:@"mulitivoice"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AudioPlayer sharePlayer] setNumberOfLoop:-1];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"answer" ofType:@"aif"];
            [[AudioPlayer sharePlayer] playWithPath:path];
            NSString *from = msg.from;
            RosterItem *ri = [USER getRosterInfoByUid:from];
            m_roomId = [msg.rid copy];
            m_invitedId = [msg.from copy];
             NSString *tip = [NSString stringWithFormat:@"%@想和你多人通话！", ri.name];
            [self showNotificationWithTitle:@"多人通话" body:tip];
            m_av = [[UIAlertView alloc] initWithTitle:@"多人通话" message:tip delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"接听", nil];
            [m_av show];
        });
        return;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AudioPlayer sharePlayer] setNumberOfLoop:-1];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"answer" ofType:@"aif"];
        [[AudioPlayer sharePlayer] playWithPath:path];
        NSString *from = msg.from;
        RosterItem *ri = [USER getRosterInfoByUid:from];
        NSString *tip = [NSString stringWithFormat:@"%@想和你视频通话！", ri.name];
        [self showNotificationWithTitle:@"多人通话" body:tip];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WebRtcRecvViewChatViewController *recvController =[sb instantiateViewControllerWithIdentifier:@"WebRtcRecvViewChatViewController"];
        recvController.rid = msg.rid;
        recvController.uid = self.uid;
        recvController.serverUrl = [NSURL URLWithString:webrtcUrl];
        recvController.talkingUid = msg.from;
        self.recvVc = recvController;
        [APP_DELEGATE.window.rootViewController presentViewController:recvController animated:YES completion:nil];
    });
    
}

- (void)showNotificationWithTitle:(NSString *)title body:(NSString *)body {
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = itemDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = body;
    localNotif.alertAction = @"查看消息";
    
    localNotif.soundName = @"answer.aif";
    localNotif.applicationIconBadgeNumber++;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)sendDeviceReceived:(NSString *)rid {
    NSArray *presenceArray = [USER.presenceMgr getPresenceMsgArrayByUid:USER.uid];
    if (presenceArray.count > 0) {
        [presenceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PresenceMsg *msg = obj;
            WebRtcNotifyMsg *recevNotify = [[WebRtcNotifyMsg alloc] initWithFrom:USER.uid to:USER.uid rid:rid];
            recevNotify.to_res = msg.from_res;
            recevNotify.contentType = @"handle";
            [USER.session post:recevNotify];
        }];
    }
}

- (void)reject {
    WebRtcNotifyMsg *nm = [[WebRtcNotifyMsg alloc] initWithFrom:USER.uid to:m_invitedId rid:m_roomId];
    nm.contentType = @"reject";
    [USER.session post:nm];
}

- (void)setbusy:(BOOL)busy {
    self.busy = busy;
}


- (void)sendSignalWithType:(NSString *)type isSelf:(BOOL)isSelf roomId:(NSString *)roomId {
    NSString *to = self.uid;
    if (isSelf) {
        to = USER.uid;
    }
    WebRtcNotifyMsg *nm = [[WebRtcNotifyMsg alloc] initWithFrom:USER.uid to:to rid:roomId];
    nm.contentType = type;
    [USER.session post:nm];
}

- (void)sendCloseSignalWithTalkingId:(NSString *)talkingId roomId:(NSString *)rid {
    WebRtcNotifyMsg *nm = [[WebRtcNotifyMsg alloc] initWithFrom:USER.uid to:talkingId rid:rid];
    nm.contentType = @"close";
    [USER.session post:nm];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[AudioPlayer sharePlayer] stop];
    switch (buttonIndex) {
        case 0:
            self.busy = NO;
            [self sendDeviceReceived:m_roomId];
            [self reject];
            break;
        case 1: {
            [self sendDeviceReceived:m_roomId];
            MultiCallViewController *vc = [[MultiCallViewController alloc] initWithNibName:@"MultiCallViewController" bundle:nil];
            vc.invited = YES;
            vc.roomId = [m_roomId copy];
            [APP_DELEGATE.window.rootViewController presentViewController:vc animated:YES completion:nil];
        }
            break;
            
        default:
            self.busy = NO;
            break;
    }
}

@end
