//
//  GroupChatQuitMsg.m
//  IM
//
//  Created by 郭志伟 on 15/9/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatQuitMsg.h"
#import "MessageConstants.h"
#import "loglevel.h"

@interface GroupChatQuitMsg()

@property(nonatomic, copy) NSString *gid;

@end

@implementation GroupChatQuitMsg

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
    
    NSDictionary *dict = @{@"msgid"   : self.qid,
                           @"type"   : @"leave",
                           @"gid"    : self.gid,
                           };
    DDLogInfo(@"--> %@", dict);
    
    NSData *data = [self jsonDataFromDict:dict];
    return data;
}

@end
