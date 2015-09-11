//
//  GroupChatNotificationTb.h
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface GroupChatNotificationTb : NSObject

- (instancetype)initWithDbq:(FMDatabaseQueue *)dbq;
- (instancetype)init NS_UNAVAILABLE;

@end
