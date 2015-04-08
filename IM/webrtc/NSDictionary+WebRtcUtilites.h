//
//  NSDictionary+WebRtcUtilites.h
//  AppRTC
//
//  Created by 郭志伟 on 15-3-24.
//  Copyright (c) 2015年 ISBX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (WebRtcUtilites)

+ (NSDictionary *)dictionaryWithJSONString:(NSString *)jsonString;
+ (NSDictionary *)dictionaryWithJSONData:(NSData *)jsonData;

@end
