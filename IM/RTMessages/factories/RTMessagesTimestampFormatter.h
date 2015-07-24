//
//  RTMessagesTimestampFormatter.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RTMessagesTimestampFormatter : NSObject

@property (strong, nonatomic, readonly) NSDateFormatter *dateFormatter;

@property (copy, nonatomic) NSDictionary *dateTextAttributes;

@property (copy, nonatomic) NSDictionary *timeTextAttributes;

+ (RTMessagesTimestampFormatter *)sharedFormatter;

- (NSString *)timestampForDate:(NSDate *)date;

- (NSAttributedString *)attributedTimestampForDate:(NSDate *)date;

- (NSString *)timeForDate:(NSDate *)date;

- (NSString *)relativeDateForDate:(NSDate *)date;

@end
