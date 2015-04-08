//
//  WebRtcSignalingMessage.h
//  IM
//
//  Created by 郭志伟 on 15-3-24.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTCSessionDescription.h"
#import "RTCICECandidate+WRJSON.h"

@interface WebRtcSignalingMessage : NSObject

+ (WebRtcSignalingMessage *)messageFromJSONString:(NSString *)jsonString;

- (NSData *)JSONData;

- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                       msgId:(NSString *)msgId
                       topic:(NSString *)topic
                     content:(NSString *)content;

@property(nonatomic, readonly) NSString *from;
@property(nonatomic, readonly) NSString *to;
@property(nonatomic, readonly) NSString *msgId;
@property(nonatomic, readonly) NSString *topic;
@property(nonatomic, strong) NSString *content;

@end


@interface WebRtcSessionDescriptionMessage : WebRtcSignalingMessage

@property(nonatomic, strong) RTCSessionDescription *sessionDescription;

@end

@interface WebRtcCreateRoomMessage : WebRtcSignalingMessage

- (void)setRoomId:(NSString *)rid uid:(NSString *)uid;
@property(nonatomic, readonly) NSString *roomId;
@property(nonatomic, readonly) NSString *uid;

@end

@interface WebRtcLeaveRoomMessage : WebRtcSignalingMessage

@property(nonatomic, strong) NSString *uid;

@end

@interface WebRtcJoinRoomMessage : WebRtcSignalingMessage

- (void)setRid:(NSString *)roomId;
@property(nonatomic, readonly) NSString *roomId;

@end


@interface WebRtcCandidateMessage: WebRtcSignalingMessage
@property(nonatomic, strong) RTCICECandidate *candidate;
@end
