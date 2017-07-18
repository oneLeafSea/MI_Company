//
//  Request.m
//  WH
//
//  Created by guozw on 14-10-9.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Request.h"

@implementation Request

- (instancetype)init {
    if (self = [super init]) {
        self.msgType = MessageTypeRequest;
        _qid = [self uuid];
    }
    return self;
}


- (NSData *)pkgData {
     NSAssert(NO, @"Subclasses need to overwrite pkgData method in your Request");
    return nil;
}

@end
