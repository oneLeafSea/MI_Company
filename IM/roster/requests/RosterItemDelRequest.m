//
//  RosterItemDelRequest.m
//  IM
//
//  Created by 郭志伟 on 15-1-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemDelRequest.h"
#import "MessageConstants.h"
#import "LogLevel.h"



@implementation RosterItemDelRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = IM_ROSTER_ITEM_DEL_REQUEST;
        self.status = RosterItemDelRequestStatusUnkown;
    }
    return self;
}

- (instancetype)initWithFrom:(NSString *)from to:(NSString *)to {
    if (self = [self init]) {
        if (from == nil || to == nil) {
            return nil;
        }
        _from = [from copy];
        _to = [to copy];
    }
    return self;
}


- (NSData *)pkgData {
    NSDictionary *dict = @{
                           @"msgid":self.qid,
                           @"from":self.from,
                           @"to": self.to
                           };
    DDLogInfo(@"--> %@", dict);
    NSData *data = [self jsonDataFromDict:dict];
    return data;
}

@end
