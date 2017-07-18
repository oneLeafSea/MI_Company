//
//  RTCICECandidate+WRJSON.h
//  AppRTC
//
//  Created by 郭志伟 on 15-3-24.
//  Copyright (c) 2015年 ISBX. All rights reserved.
//

#import "RTCICECandidate.h"

@interface RTCICECandidate (WRJSON)

+ (RTCICECandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary;
- (NSData *)JSONData;


@end
