//
//  RTCSessionDescription+WRJSON.m
//  AppRTC
//
//  Created by 郭志伟 on 15-3-24.
//  Copyright (c) 2015年 ISBX. All rights reserved.
//

#import "RTCSessionDescription+WRJSON.h"

static NSString const *kRTCSessionDescriptionTypeKey = @"type";
static NSString const *kRTCSessionDescriptionSdpKey = @"sdp";

@implementation RTCSessionDescription (WRJSON)

+ (RTCSessionDescription *)descriptionFromJSONDictionary:
(NSDictionary *)dictionary {
    NSString *type = dictionary[kRTCSessionDescriptionTypeKey];
    NSString *sdp = dictionary[kRTCSessionDescriptionSdpKey];
    return [[RTCSessionDescription alloc] initWithType:type sdp:sdp];
}

- (NSData *)JSONData {
    NSDictionary *json = @{
                           kRTCSessionDescriptionTypeKey : self.type,
                           kRTCSessionDescriptionSdpKey : self.description
                           };
    return [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
}

@end
