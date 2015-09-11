//
//  GroupChatNotifyMsg.h
//  IM
//
//  Created by 郭志伟 on 15/9/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "Request.h"

@interface GroupChatNotifyMsg : Request

- (instancetype)initWithData:(NSData *)data;

@property(nonatomic, readonly) NSString *from;
@property(nonatomic, readonly) NSString *from_res;
@property(nonatomic, readonly) NSString *to;
@property(nonatomic, readonly) NSString *gid;
@property(nonatomic, readonly) NSString *gname;
@property(nonatomic, readonly) NSString *notifytype;

@end
