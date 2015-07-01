//
//  NSString+URL.m
//  IM
//
//  Created by 郭志伟 on 15/6/18.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString (URL)

- (NSString *)URLEncodedString
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            NULL,
                                            (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                            kCFStringEncodingUTF8));
    return encodedString;
}

- (NSString *)URLDecodedString {
    NSString *decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
    return decoded;
}

//- (NSString *)GBK2UTF8 {
//    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    NSData *responseData =[self dataUsingEncoding:encode ];
//    NSString *utf8Str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    return utf8Str;
//}

@end
