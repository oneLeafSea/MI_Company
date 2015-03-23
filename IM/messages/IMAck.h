//
//  IMAck.h
//  IM
//
//  Created by 郭志伟 on 15-1-5.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"

extern NSInteger kIMAckErrorCode;
extern NSString *kIMAckNotification;


@interface IMAck : Request

- (instancetype)initWithData:(NSData *)data;

- (instancetype)initWithMsgid:(NSString *)msgid
                      ackType:(UInt32)type
                         time:(NSString *)time
                          err:(NSString *)err;



@property NSString *msgid;
@property UInt32   ackType;
@property(nonatomic) NSError *error;
@property NSString *time;

@end
