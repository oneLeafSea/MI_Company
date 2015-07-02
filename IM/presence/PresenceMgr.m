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

- (void)postMsgWithPresenceType:(NSString *)presencetype presenceShow:(NSString *)presenceShow sign:(NSString *)sign {
    PresenceMsg *msg = [[PresenceMsg alloc] initWithPresenceType:presencetype show:presenceShow];
    msg.sign = sign;
    [USER.session post:msg];
}

- (NSArray *)getPresenceMsgArrayByUid:(NSString *)uid {
    return [m_presenceInfo objectForKey:uid];
}

- (BOOL) isOnline:(NSString *)uid {
    NSArray *msgArray = [self getPresenceMsgArrayByUid:uid];
    __block BOOL online = NO;
    if (msgArray) {
        [msgArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PresenceMsg *msg = obj;
            if ([msg.show isEqualToString:kPresenceTypeOnline]) {
                online = YES;
                *stop = YES;
            }
        }];
    }
    return online;
}


- (void)handlePresenceNotification:(NSNotification *)notification {
    __block PresenceMsg *msg = notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([msg.presenceType isEqualToString:kPresenceTypeLeave]) {
            NSMutableArray *presenceArray = [m_presenceInfo objectForKey:msg.from];
            if (presenceArray) {
                __block NSInteger delIdx = 0;
                [presenceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    PresenceMsg *m = obj;
                    if ([m.from_res isEqualToString:msg.from_res]) {
                        delIdx = idx;
                        *stop = YES;
                    }
                }];
                [presenceArray removeObjectAtIndex:delIdx];
                if (presenceArray.count == 0) {
                    [m_presenceInfo removeObjectForKey:msg.from];
                }
            }
            
        }
        
        if ([msg.presenceType isEqualToString:kPresenceTypeOnline]) {
            [self addToPreseceInfo:msg];
            [self ackPresenceWithUid:msg.from toRes:msg.from_res];
        }
        
        if ([msg.presenceType isEqualToString:kPresenceTypeUpdate]) {
            DDLogInfo(@"INFO: presence state.");
        }
        
        if ([msg.presenceType isEqualToString:kPresenceTypeAck]) {
            [self addToPreseceInfo:msg];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kPresenceChangedNotification object:nil];
    });
}

- (void)addToPreseceInfo:(PresenceMsg *)msg {
    NSMutableArray *presenceArray = [m_presenceInfo objectForKey:msg.from];
    if (!presenceArray) {
        presenceArray = [[NSMutableArray alloc] init];
       
    } else {
        __block BOOL found = NO;
        __block NSUInteger i = 0;
        [presenceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PresenceMsg *m = obj;
            if ([m.from_res isEqualToString:msg.from_res]) {
                found = YES;
                i = idx;
                *stop = YES;
            }
        }];
        if (found) {
            [presenceArray removeObjectAtIndex:i];
        }
    }
     [presenceArray addObject:msg];
    [m_presenceInfo setObject:presenceArray forKey:msg.from];
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
