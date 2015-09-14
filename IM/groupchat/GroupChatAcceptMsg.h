//
//  GroupChatAcceptMsg.h
//  IM
//
//  Created by 郭志伟 on 15/9/14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "Request.h"

@interface GroupChatAcceptMsg : Request

- (instancetype)initWithGid:(NSString *)gid msgid:(NSString *)msgid;

@end
