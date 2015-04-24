//
//  ChatMessageSQL.m
//  IM
//
//  Created by 郭志伟 on 15-1-16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageSQL.h"

NSString *kSQLChatMessageCreate = @"CREATE TABLE IF NOT EXISTS `tb_message` ("
                                    "`msgid`	TEXT,"
                                    "`body`	TEXT NOT NULL,"
                                    "`from`	TEXT NOT NULL,"
                                    "`to`	TEXT NOT NULL,"
                                    "`type`	INTEGER NOT NULL,"
                                    "`fromRes`	TEXT,"
                                    "`toRes`	TEXT,"
                                    "`status`	INTEGER,"
                                    "`time`	TEXT NOT NULL,"
                                    "PRIMARY KEY(msgid)"
                                    ")";

NSString *kSQLChatMessageInsert = @"INSERT INTO `tb_message` (`msgid`, `from`, `to`, `body`, `time`, `type`, `fromRes`, `toRes`, `status`) VALUES("
                                    "?,"
                                    "?,"
                                    "?,"
                                    "?,"
                                    "?,"
                                    "?,"
                                    "?,"
                                    "?,"
                                    "?"
                                    ");";

NSString *kSQLChatMessageExistMsgId = @"SELECT * FROM `tb_message` WHERE `msgid` = ?;";

NSString *kSQLChatMessageUpdateStatus = @"UPDATE `tb_message` SET "
                                         "status = ?"
                                         " WHERE "
                                         "msgid = ?";

NSString *kSQLChatMessageUpdateTime = @"UPDATE `tb_message` SET "
                                            "time = ?"
                                            " WHERE "
                                            "msgid = ?";

NSString *KSQLChatMessageGetMsg = @"SELECT * FROM (SELECT * FROM `tb_message` WHERE (`from` = ? OR `to` = ?) AND type = ? ORDER BY `time` DESC LIMIT ? OFFSET ?) ORDER BY `time` ASC";

NSString *kSQLChatMessageGetLastGrpChatMsg = @"SELECT * FROM `tb_message` WHERE `to` = ? ORDER BY `time` DESC LIMIT 1";







