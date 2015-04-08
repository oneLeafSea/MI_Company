//
//  WebRtcAckMessage.m
//  IM
//
//  Created by 郭志伟 on 15-3-25.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "WebRtcAckMessage.h"
#import "NSDictionary+WebRtcUtilites.h"

@implementation WebRtcAckMessage

- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                       msgId:(NSString *)msgId
                       topic:(NSString *)topic
                     content:(NSString *)content {
    if (self = [super initWithFrom:from to:to msgId:msgId topic:topic content:content]) {
        NSDictionary *jsonContent = [NSDictionary dictionaryWithJSONString:content];
        _ack = [jsonContent objectForKey:@"ack"];
        _desp = [jsonContent objectForKey:@"desp"];
    }
    return self;
}

@end
