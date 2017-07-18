//
//  IMAck.m
//  IM
//
//  Created by 郭志伟 on 15-1-5.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "IMAck.h"
#import "LogLevel.h"
#import "MessageConstants.h"
#import "NSDate+Common.h"

NSInteger kIMAckErrorCode = 40000;
NSString *kIMAckNotification = @"cn.com.rooten.im.ack";

@implementation IMAck

- (instancetype)init {
    if (self = [super init]) {
        self.type = IM_MESSAGE_ACK;
    }
    return self;
}


- (instancetype)initWithData:(NSData *)data {
    if (self = [self init]) {
        if (![self setup:data]) {
            self = nil;
        }
    }
    return self;
}

- (instancetype)initWithMsgid:(NSString *)msgid
                      ackType:(UInt32)type
                         time:(NSString *)time
                          err:(NSString *)err; {
    if (self = [self init]) {
        if (msgid == nil) {
            return nil;
        }
        self.msgid = [msgid copy];
        self.ackType = type;
        self.qid = self.msgid;
        self.time = [[NSDate Now] formatWith:nil];
        if (err) {
            self.error = [[NSError alloc] initWithDomain:@"IM" code:kIMAckErrorCode userInfo:@{@"err":err}];
        }
        
    }
    return self;
}

- (BOOL)setup:(NSData *)data {
    NSDictionary *dict = [self dictFromJsonData:data];
    DDLogInfo(@"<-- %@", dict);
    self.msgid = [dict objectForKey:@"msgid"];
    if (self.msgid == nil) {
        DDLogError(@"ERROR: IM ACK do not have msgid key.");
        return NO;
    }
    
    NSNumber *type = [dict objectForKey:@"type"];
    self.ackType = [type unsignedIntValue];

    NSString *err = [dict objectForKey:@"err"];
    if (err != nil) {
        self.error = [[NSError alloc] initWithDomain:@"IM" code:kIMAckErrorCode userInfo:@{@"err":err}];
    }
    
    self.time = [dict objectForKey:@"time"];
    return YES;
}

- (NSData *)pkgData {
    NSNumber *type = [NSNumber numberWithUnsignedInt:self.ackType];
    NSDictionary *dict = @{
                           @"msgid" : self.qid,
                           @"type"  : type,
                           @"time"  : self.time
                           };
    
    DDLogInfo(@"--> %@", dict);
    NSData *data = [self jsonDataFromDict:dict];
    return data;
}

@end
