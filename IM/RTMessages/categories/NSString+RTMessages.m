//
//  NSString+RTMessages.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "NSString+RTMessages.h"

@implementation NSString (RTMessages)

- (NSString *)rt_stringByTrimingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
