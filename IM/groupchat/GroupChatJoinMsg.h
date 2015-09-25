//
//  GroupChatJoinMsg.h
//  IM
//
//  Created by 郭志伟 on 15/9/24.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "Request.h"

@interface GroupChatJoinMsg : Request

- (instancetype)initWithData:(NSData *)data;

@property(nonatomic, copy, readonly)NSString *gid;
@property(nonatomic, copy, readonly)NSString *uid;

@end
