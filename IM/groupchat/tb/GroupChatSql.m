//
//  GroupChatSql.m
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatSql.h"

NSString * const kSqlGroupChatNotifyCreate = @"CREATE TABLE IF NOT EXISTS `tb_grpchat_notify` ("
                                                "`msg_id`	TEXT,"
                                                "`from`	TEXT,"
                                                "`to`	TEXT,"
                                                "`notify_type`	TEXT,"
                                                "`content`	TEXT,"
                                                "PRIMARY KEY(msg_id)"
                                                ");";
