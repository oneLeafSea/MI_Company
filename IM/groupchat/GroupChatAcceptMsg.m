//
//  GroupChatAcceptMsg.m
//  IM
//
//  Created by 郭志伟 on 15/9/14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatAcceptMsg.h"
#import "LogLevel.h"
#import "MessageConstants.h"


@interface GroupChatAcceptMsg()

@property(nonatomic, copy) NSString *gid;
@property(nonatomic, copy) NSString *msgid;

@end

@implementation GroupChatAcceptMsg

- (instancetype)init {
    if (self = [super init]) {
        self.type = IM_CHATROOM;
    }
    return self;
}

- (instancetype)initWithGid:(NSString *)gid msgid:(NSString *)msgid {
    if (self = [self init]) {
        self.gid = gid;
        self.msgid = msgid;
    }
    return self;
}


- (NSData *)pkgData {
    
    NSDictionary *dict = @{@"msgid"   : self.msgid,
                           @"type"   : @"reply",
                           @"gid"    : self.gid,
                           @"fname"  : @"gzw",
                           @"accept": @YES,
                           };
    DDLogInfo(@"--> %@", dict);
    
    NSData *data = [self jsonDataFromDict:dict];
    return data;
}

@end
