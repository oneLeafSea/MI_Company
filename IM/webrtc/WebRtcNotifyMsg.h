//
//  WebRtcNotifyMsg.h
//  IM
//
//  Created by 郭志伟 on 15-3-26.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "request.h"

static NSString *kWebRtcNotifyMsgNotificaiton = @"cn.com.rooten.im.WebRtcNotifyMsgNotificaiton";

@interface WebRtcNotifyMsg : Request

- (instancetype)initWithData:(NSData *)data;

- (instancetype)initWithFrom:(NSString *)from to:(NSString *)to rid:(NSString *)rid;

@property(nonatomic, strong) NSString *time;
@property(nonatomic, readonly) NSString *rid;
@property(nonatomic, readonly) NSString *from;
@property(nonatomic, readonly) NSString *from_res;
@property(nonatomic, readonly) NSString *to;
@property(nonatomic, strong) NSString *contentType;
@property(readonly)         NSDictionary *content;

@end
