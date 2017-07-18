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
                                                "`gid`	TEXT,"
                                                "`gname` TEXT,"
                                                "`processed`	INTEGER DEFAULT 0,"
                                                "`time` TEXT,"
                                                "PRIMARY KEY(msg_id)"
                                                ");";

NSString * const kSqlGroupChatNotifyInsert = @"INSERT INTO `tb_grpchat_notify`(`msg_id`, `from`, `to`, `notify_type`, `content`, `gid`, `gname`, `processed`, time) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?);";

NSString * const kSqlGroupChatNotifyInvitation = @"SELECT * FROM `tb_grpchat_notify` WHERE `notify_type` = 'invent' ORDER BY `time` DESC;";

NSString *const kSqlGroupChatNotifyUpdate = @"UPDATE `tb_grpchat_notify`SET `processed` = ? WHERE `gid` = ?;";

NSString *const kSqlGroupChatNotifyClear = @"DELETE FROM `tb_grpchat_notify`;";
