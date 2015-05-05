//
//  WebRtcSignalingMessage.m
//  IM
//
//  Created by 郭志伟 on 15-3-24.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "WebRtcSignalingMessage.h"


#import "NSDictionary+WebRtcUtilites.h"
#import "RTCSessionDescription+WRJSON.h"
#import "RTCICECandidate+WRJSON.h"
#import "Utils.h"
#import "LogLevel.h"


static NSString const *kWebRtcSignalingMessageTypeKey = @"type";

@implementation WebRtcSignalingMessage

+ (WebRtcSignalingMessage *)messageFromJSONString:(NSString *)jsonString {
    
    NSDictionary *values = [NSDictionary dictionaryWithJSONString:jsonString];
    if (!values) {
        NSLog(@"Error parsing signaling message JSON.");
        return nil;
    }
    WebRtcSignalingMessage *message = nil;
    NSString *topic = [values objectForKey:@"topic"];
    NSString *from = [values objectForKey:@"from"];
    NSString *fromRes = [values objectForKey:@"from_res"];
    NSString *to = [values objectForKey:@"to"];
    NSString *toRes = [values objectForKey:@"to_res"];
    NSString *msgId = [values objectForKey:@"msgid"];
    NSString *content = [values objectForKey:@"content"];
    if ([topic isEqualToString:@"create"]) {
        message = [[WebRtcCreateRoomMessage alloc] initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content];
    } else if ([topic isEqualToString:@"join"]) {
        message = [[WebRtcJoinRoomMessage alloc] initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content];
    } else if ([topic isEqualToString:@"leave"]) {
        message = [[WebRtcLeaveRoomMessage alloc] initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content];
    } else if ([topic isEqualToString:@"message"]) {
        NSDictionary *jsonContent = [NSDictionary dictionaryWithJSONString:content];
        NSString *typeString = [jsonContent objectForKey:@"type"];
        if ([typeString isEqualToString:@"offer"] ||
            [typeString isEqualToString:@"answer"]) {
            message = [[WebRtcSessionDescriptionMessage alloc] initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content];
        } else if ([typeString isEqualToString:@"candidate"]) {
            message = [[WebRtcCandidateMessage alloc] initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content];
        } else if ([typeString isEqualToString:@"video"]) {
            message = [[WebRtcVideoMessage alloc] initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content];
        } else {
            NSLog(@"Unexpected content type: %@", typeString);
        }
    } else if ([topic isEqualToString:@"seq"]) {
        message = [[WebRtcSeqMessage alloc] initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content];
    } else {
        NSLog(@"Unexpected topic: %@", topic);
    }
    return message;
}

- (instancetype)initWithFrom:(NSString *)from
                     fromRes:(NSString *)fromRes
                          to:(NSString *)to
                       toRes:(NSString *)toRes
                       msgId:(NSString *)msgId
                       topic:(NSString *)topic
                     content:(NSString *)content{
    NSParameterAssert(topic.length);
    if (self = [super init]) {
        _topic = topic;
        _from = from;
        _to = to;
        _msgId = msgId;
        _content = content;
        _fromRes = fromRes;
        _toRes = toRes;
    }
    return self;
}

- (NSString *)description {
    return [[NSString alloc] initWithData:[self JSONData]
                                 encoding:NSUTF8StringEncoding];
}

- (NSData *)JSONData {
    NSDictionary *dict = @{
                           @"from":_from,
                           @"from_res":_fromRes ? _fromRes : @"",
                           @"to":_to,
                           @"to_res":_toRes ? _toRes : @"",
                           @"topic":_topic,
                           @"msgid":_msgId,
                           @"content":[self contentData]
                           };
    DDLogInfo(@"INFO:%@", dict);
    return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
}

- (NSString *)contentData {
    return nil;
}

@end


@implementation WebRtcSessionDescriptionMessage

- (instancetype)initWithFrom:(NSString *)from
                     fromRes:(NSString *)fromRes
                          to:(NSString *)to
                       toRes:(NSString *)toRes
                       msgId:(NSString *)msgId
                       topic:(NSString *)topic
                     content:(NSString *)content {
    if (self = [super initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content]) {
        if (content) {
            NSDictionary *jsonContent = [NSDictionary dictionaryWithJSONString:content];
            NSString *typeString = [jsonContent objectForKey:@"type"];
            if ([typeString isEqualToString:@"offer"] ||
                [typeString isEqualToString:@"answer"]) {
                _sessionDescription = [RTCSessionDescription descriptionFromJSONDictionary:jsonContent];
            } else {
                NSAssert(NO, @"Unexpected type: %@", typeString);
            }
        }
    }
    return self;
}

- (NSString *)contentData {
    NSString *str = [[NSString alloc] initWithData:[_sessionDescription JSONData]
                                          encoding:NSUTF8StringEncoding];
    return str;
}

@end

@implementation WebRtcCreateRoomMessage


- (instancetype)initWithFrom:(NSString *)from
                     fromRes:(NSString *)fromRes
                          to:(NSString *)to
                       toRes:(NSString *)toRes
                       msgId:(NSString *)msgId
                       topic:(NSString *)topic
                     content:(NSString *)content {
    if (self = [super initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content]) {
        if (content) {
            NSDictionary *jsonContent = [NSDictionary dictionaryWithJSONString:content];
            _roomId = [jsonContent objectForKey:@"rid"];
            _uid = from;
        }
    }
    return self;
}

- (void)setRoomId:(NSString *)rid uid:(NSString *)uid {
    _roomId = rid;
    _uid = uid;
}

- (NSString *)contentData {
    NSDictionary *dict = @{
                           @"rid":_roomId,
                           @"signatrue":_seq,
                           @"token":_token
                           };
    NSData *data = [Utils jsonDataFromDict:dict];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

@end


@implementation WebRtcLeaveRoomMessage

- (instancetype)initWithFrom:(NSString *)from
                     fromRes:(NSString *)fromRes
                          to:(NSString *)to
                       toRes:(NSString *)toRes
                       msgId:(NSString *)msgId
                       topic:(NSString *)topic
                     content:(NSString *)content {
    if (self = [super initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content]) {
        if (content) {
            NSDictionary *jsonContent = [NSDictionary dictionaryWithJSONString:content];
            _uid = [jsonContent objectForKey:@"uid"];
            _deviceType = [jsonContent objectForKey:@"res"];
        }
    }
    return self;
}

- (NSString *)contentData {
    NSDictionary *dict = @{
                           @"uid":_uid
                           };
    NSData *data = [Utils jsonDataFromDict:dict];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

@end


@implementation WebRtcJoinRoomMessage

- (instancetype)initWithFrom:(NSString *)from
                     fromRes:(NSString *)fromRes
                          to:(NSString *)to
                       toRes:(NSString *)toRes
                       msgId:(NSString *)msgId
                       topic:(NSString *)topic
                     content:(NSString *)content {
    if (self = [super initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content]) {
        if (content) {
            NSDictionary *jsonContent = [NSDictionary dictionaryWithJSONString:content];
            _roomId = [jsonContent objectForKey:@"rid"];
        }
    }
    return self;
}

- (void)setRid:(NSString *)roomId {
    _roomId = roomId;
}

- (NSString *)contentData {
    NSDictionary *dict = @{
                           @"rid":_roomId,
                           @"signatrue":_seq,
                           @"token":_token
                           };
    NSData *data = [Utils jsonDataFromDict:dict];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

@end

@implementation WebRtcCandidateMessage

- (instancetype)initWithFrom:(NSString *)from
                     fromRes:(NSString *)fromRes
                          to:(NSString *)to
                       toRes:(NSString *)toRes
                       msgId:(NSString *)msgId
                       topic:(NSString *)topic
                     content:(NSString *)content {
    if (self = [super initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content]) {
        if (content) {
            NSDictionary *jsonContent = [NSDictionary dictionaryWithJSONString:content];
            RTCICECandidate *candidate = [RTCICECandidate candidateFromJSONDictionary:jsonContent];
            NSParameterAssert(candidate);
            _candidate = candidate;
        }
        
    }
    return self;
}

- (NSString *)contentData {
    NSString *str = [[NSString alloc] initWithData:[_candidate JSONData] encoding:NSUTF8StringEncoding];
    return str;
}

@end

@implementation WebRtcSeqMessage

- (instancetype)initWithFrom:(NSString *)from
                     fromRes:(NSString *)fromRes
                          to:(NSString *)to
                       toRes:(NSString *)toRes
                       msgId:(NSString *)msgId
                       topic:(NSString *)topic
                     content:(NSString *)content {
    if (self = [super initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content]) {
        if (content) {
            NSDictionary *jsonContent = [NSDictionary dictionaryWithJSONString:content];
            _seq = [jsonContent objectForKey:@"seq"];
        }
    }
    return self;
}

- (NSString *)contentData {
    NSAssert(NO, @"不会运行到此函数。");
    return nil;
}

@end

@implementation WebRtcVideoMessage

- (instancetype)initWithFrom:(NSString *)from
                     fromRes:(NSString *)fromRes
                          to:(NSString *)to
                       toRes:(NSString *)toRes
                       msgId:(NSString *)msgId
                       topic:(NSString *)topic
                     content:(NSString *)content {
    if (self = [super initWithFrom:from fromRes:fromRes to:to toRes:toRes msgId:msgId topic:topic content:content]) {
        if (content) {
            NSDictionary *jsonContent = [NSDictionary dictionaryWithJSONString:content];
            NSString *enable = [jsonContent objectForKey:@"videoenable"];
            if ([enable isEqualToString:@"true"]) {
                _enable = YES;
            } else {
                _enable = NO;
            }
        }
    }
    return self;
}

- (NSString *)contentData {
    NSDictionary *dict = @{
                           @"type":@"video",
                           @"videoenable":self.enable ? @"true": @"false",
                           };
    NSData *data = [Utils jsonDataFromDict:dict];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

@end