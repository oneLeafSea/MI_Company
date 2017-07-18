//
//  Response.m
//  WH
//
//  Created by 郭志伟 on 14-10-14.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Response.h"

@implementation Response


- (instancetype)init {
    if (self = [super init]) {
        self.msgType = MessageTypeResponse;
    }
    return self;
}

- (BOOL)parseData:(UInt32)type data:(NSData *)data {
    return YES;
}

@end
