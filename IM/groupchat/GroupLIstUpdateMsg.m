//
//  GroupLIstUpdateMsg.m
//  IM
//
//  Created by 郭志伟 on 15/9/21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupLIstUpdateMsg.h"
#import "LogLevel.h"
#import "MessageConstants.h"

@implementation GroupLIstUpdateMsg

- (instancetype)init {
    if (self = [super init]) {
        self.type = IM_NOTIFY_GRP_LIST_UPDATE;
    }
    return self;
}

- (NSData *)pkgData {
    NSDictionary *dict = @{@"msgid"   : self.qid,
                           @"from"    : self.from,
                           @"to"      : self.to,
                           @"from_res": @"iphone"
                           };
    DDLogInfo(@"--> %@", dict);
    
    NSData *data = [self jsonDataFromDict:dict];
    return data;
}

@end
