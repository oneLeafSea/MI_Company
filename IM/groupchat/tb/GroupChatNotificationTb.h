//
//  GroupChatNotificationTb.h
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "GroupChatNotifyMsg.h"


@interface GroupChatNotificationTb : NSObject

- (instancetype)initWithDbq:(FMDatabaseQueue *)dbq;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)insertNotification:(GroupChatNotifyMsg *) msg fromname:(NSString *)fromname;
- (NSArray *)getInvitationNotifcations;

- (BOOL)updateNotificationProcessedWithGid:(NSString *)gid;

- (BOOL)clearDb;

@end
