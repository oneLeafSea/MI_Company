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
        fmt = @"yyyy-MM-dd HH:mm:ss.SSSSSS";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fmt];
    NSString *dateStr = [dateFormatter stringFromDate:self];
    return dateStr;
}

+ (instancetype)dateWithFormater:(NSString *) formater stringTime:(NSString *)stringTime {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:formater];
    NSDate *date = [dateFormat dateFromString:stringTime];
    return date;
}

+ (NSString *) stringNow {
    NSDate *now = [NSDate Now];
    return [now formatWith:nil];
}

@end
