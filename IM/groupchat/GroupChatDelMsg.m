//
//  GroupChatDelMsg.m
//  IM
//
//  Created by 郭志伟 on 15/9/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatDelMsg.h"
#import "MessageConstants.h"
#import "loglevel.h"

@interface GroupChatDelMsg()

@property(nonatomic, copy) NSString *gid;

@end

@implementation GroupChatDelMsg

- (instancetype)init {
    if (self = [super init]) {
        self.type = IM_CHATROOM;
    }
    return self;
}

- (instancetype)initWithGid:(NSString *)gid {
    if (self = [self init]) {
        self.gid = gid;
    }
    return self;
}


- (NSData *)pkgData {
    
    NSDictionary *dict = @{kMsgQid   : self.qid,
                           @"type"   : @"del",
                           @"gid"    : self.gid,
                           };
    DDLogInfo(@"--> %@", dict);
    
    NSData *data = [self jsonDataFromDict:dict];
    return data;
}

@end
