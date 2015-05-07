//
//  PresenceMgr.m
//  IM
//
//  Created by 郭志伟 on 15-2-19.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "PresenceMgr.h"
#import "AppDelegate.h"
#import "PresenceMsg.h"
#import "PresenceNotification.h"
#import "IMAck.h"
#import "MessageConstants.h"
#import "LogLevel.h"


@interface PresenceMgr() {
    NSMutableDictionary *m_presenceInfo;
}
@end

@implementation PresenceMgr

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPresenceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kIMAckNotification object:nil];
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePresenceNotification:) name:kPresenceNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAckNotification:) name:kIMAckNotification object:nil];
        m_presenceInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) postMsgWithPresenceType:(NSString *)presencetype
                    presenceShow:(NSString *)presenceShow {
    PresenceMsg *msg = [[PresenceMsg alloc] initWithPresenceType:presencetype show:presenceShow];
    [USER.session post:msg];
}

- (PresenceMsg *)getPresenceMsgByUid:(NSString *)uid {
    return [m_presenceInfo objectForKey:uid];
}

- (BOOL) isOnline:(NSString *)uid {
    PresenceMsg *msg = [self getPresenceMsgByUid:uid];
    if (msg && [msg.show isEqualToString:kPresenceTypeOnline]) {
        return YES;
    }
    return NO;
}


- (void)handlePresenceNotification:(NSNotification *)notification {
    __block PresenceMsg *msg = notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([msg.presenceType isEqualToString:kPresenceTypeLeave]) {
            [m_presenceInfo removeObjectForKey:msg.from];
        }
        
        if ([msg.presenceType isEqualToString:kPresenceTypeOnline]) {
            [m_presenceInfo setObject:msg forKey:msg.from];
            [USER.presenceMgr ackPresenceWithUid:msg.from toRes:msg.from_res];
        }
        
        if ([msg.presenceType isEqualToString:kPresenceTypeState]) {
            DDLogInfo(@"INFO: presence state.");
        }
        
        if ([msg.presenceType isEqualToString:kPresenceTypeAck]) {
            [m_presenceInfo setObject:msg forKey:msg.from];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kPresenceChangedNotification object:nil];
    });
}

- (void) ackPresenceWithUid:(NSString *)uid toRes:(NSString *)toRes {
    NSParameterAssert(uid);
    NSParameterAssert(toRes);
    PresenceMsg *msg = [[PresenceMsg alloc] initWithPresenceType:kPresenceTypeAck show:kPresenceShowOnline];
    msg.to = [uid copy];
    msg.to_res = [toRes copy];
    [USER.session post:msg];
}

- (void)handleAckNotification:(NSNotification *)notification {
    IMAck *ack = notification.object;
    if (ack.ackType == IM_PRESENCE) {
        if (ack.error) {
            DDLogError(@"ERROR: Presence error.");
        }
    }
}

@end
