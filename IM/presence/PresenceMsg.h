//
//  PresenceMsg.h
//  IM
//
//  Created by 郭志伟 on 15-2-19.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "Request.h"

extern NSString *kPresenceTypeOnline;
extern NSString *kPresenceTypeLeave;
extern NSString *kPresenceTypeState;
extern NSString *kPresenceTypeAck;

extern NSString *kPresenceShowOnline;
extern NSString *kPresenceShowOffline;
extern NSString *kPresenceShowChat;
extern NSString *kPresenceShowDnd;
extern NSString *kPresenceShowAway;
extern NSString *kPresenceShowXa;

@interface PresenceMsg : Request

- (instancetype)initWithPresenceType:(NSString *)presenceType show:(NSString *)presenceShow;

- (instancetype)initWithData:(NSData *)data;

//- (instancetype)initAckPresenceWith

@property(readonly) NSString *presenceType;
@property(readonly) NSString *show;
@property(readonly) NSString *from;
@property(readonly) NSString *from_res;
@property NSString *to;
@property NSString *to_res;

@end
