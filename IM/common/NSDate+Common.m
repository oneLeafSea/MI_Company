//
//  NSDate+Common.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "NSDate+Common.h"

@implementation NSDate (Common)

+ (instancetype) Now {
    return [[self alloc] init];
}

- (NSString *)formatWith:(NSString *)fmt {
    if (fmt == nil) {
        fmt = @"yyyy-MM-dd HH:mm:ss";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fmt];
    NSString *dateStr = [dateFormatter stringFromDate:self];
    return dateStr;
}

@end
