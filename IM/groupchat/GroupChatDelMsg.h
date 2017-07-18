//
//  GroupChatDelMsg.h
//  IM
//
//  Created by 郭志伟 on 15/9/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "Request.h"

@interface GroupChatDelMsg : Request

- (instancetype)initWithGid:(NSString *)gid;

@end
