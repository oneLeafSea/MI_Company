//
//  RTCICECandidate+WRJSON.m
//  AppRTC
//
//  Created by 郭志伟 on 15-3-24.
//  Copyright (c) 2015年 ISBX. All rights reserved.
//

#import "RTCICECandidate+WRJSON.h"

static NSString const *kRTCICECandidateTypeKey = @"type";
static NSString const *kRTCICECandidateTypeValue = @"candidate";
static NSString const *kRTCICECandidateMidKey = @"sdpMid";
static NSString const *kRTCICECandidateMLineIndexKey = @"sdpMLineIndex";
static NSString const *kRTCICECandidateSdpKey = @"candidate";

@implementation RTCICECandidate (WRJSON)

+ (RTCICECandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary {
    NSString *mid = dictionary[kRTCICECandidateMidKey];
    NSString *sdp = dictionary[kRTCICECandidateSdpKey];
    NSString *num = dictionary[kRTCICECandidateMLineIndexKey];
    NSInteger mLineIndex = [num integerValue];
    return [[RTCICECandidate alloc] initWithMid:mid index:mLineIndex sdp:sdp];
}

- (NSData *)JSONData {
    NSDictionary *json = @{
                           kRTCICECandidateTypeKey : kRTCICECandidateTypeValue,
                           kRTCICECandidateMLineIndexKey : [NSString stringWithFormat:@"%d", self.sdpMLineIndex],
                           kRTCICECandidateMidKey : self.sdpMid,
                           kRTCICECandidateSdpKey : self.sdp
                           };
    NSError *error = nil;
    NSData *data =
    [NSJSONSerialization dataWithJSONObject:json
                                    options:NSJSONWritingPrettyPrinted
                                      error:&error];
    if (error) {
        NSLog(@"Error serializing JSON: %@", error);
        return nil;
    }
    return data;
}

@end
