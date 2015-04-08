//
//  RTCSessionDescription+WRJSON.h
//  AppRTC
//
//  Created by 郭志伟 on 15-3-24.
//  Copyright (c) 2015年 ISBX. All rights reserved.
//

#import "RTCSessionDescription.h"

@interface RTCSessionDescription (WRJSON)

+ (RTCSessionDescription *)descriptionFromJSONDictionary:
(NSDictionary *)dictionary;
- (NSData *)JSONData;

@end
