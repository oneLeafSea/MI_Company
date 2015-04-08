//
//  WebRtcAckMessage.h
//  IM
//
//  Created by 郭志伟 on 15-3-25.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRtcSignalingMessage.h"

static NSString *kWebRtcAckMessageError = @"0";
static NSString *kWebRtcAckMessageOK    = @"1";

@interface WebRtcAckMessage : WebRtcSignalingMessage

@property(nonatomic) NSString *ack;
@property(nonatomic) NSString *desp;

@end
