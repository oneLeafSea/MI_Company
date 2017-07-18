//
//  GroupChatInviteMsg.m
//  IM
//
//  Created by 郭志伟 on 15/9/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatInviteMsg.h"
#import "MessageConstants.h"
#import "loglevel.h"

@interface GroupChatInviteMsg()

@property(nonatomic, copy) NSString *gid;
@property(nonatomic, copy) NSString *gtype;
@property(nonatomic, copy) NSString *gname;
@property(nonatomic, strong) NSArray *peers;

@end

@implementation GroupChatInviteMsg

- (instancetype)init {
    if (self = [super init]) {
        self.type = IM_CHATROOM;
    }
    return self;
}

- (instancetype)initWithGid:(NSString *)gid
                       type:(NSString *)type
                      gname:(NSString *)gname
                      peers:(NSArray *)peers {
    if (self = [self init]) {
        self.gid = gid;
        self.gtype = type;
        self.gname = gname;
        self.peers = peers;
    }
    return self;
}


- (NSData *)pkgData {
    
    NSDictionary *dict = @{kMsgQid   : self.qid,
                           @"type"   : self.gtype,
                           @"gid"    : self.gid,
                           @"gname"  : self.gname,
                           @"peers"  : self.peers,
                                };
    DDLogInfo(@"--> %@", dict);
    
    NSData *data = [self jsonDataFromDict:dict];
    return data;
}

@end
