//
//  RecentSql.m
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RecentSql.h"

NSString *kSQLRecentCreate = @"CREATE TABLE IF NOT EXISTS `tb_recent` ("
                                "`msgid`	TEXT,"
                                "`from`	TEXT,"
                                "`to`	TEXT,"
                                "`msgtype`	INTEGER NOT NULL,"
                                "`content`	TEXT,"
                                "`time`	TEXT,"
                                "`badge` TEXT,"
                                "`ext` TEXT"
                                ");";

NSString *kSQLRecentGetAll = @"SELECT * FROM `tb_recent` ORDER BY `time` DESC;";


NSString *kSQLRecentInsert = @"INSERT INTO `tb_recent` (`msgid`, `from`, `to`, `msgtype`, `content`, `time`, `badge`, `ext`) VALUES ("
                                "?,"
                                "?,"
                                "?,"
                                "?,"
                                "?,"
                                "?,"
                                "?,"
                                "?);";

NSString *kSQLRecentExsitFrom = @"SELECT * FROM `tb_recent` WHERE `from` = ? AND `msgtype` = ?";

NSString *kSQLRecentExsitFromOrTo = @"SELECT * FROM `tb_recent` WHERE (`from` = ? OR `to` = ?) AND `msgtype` = ?;";

NSString *kSQLRecentExsitFromOrToWithExt = @"SELECT * FROM `tb_recent` WHERE (`from` = ? OR `to` = ?) AND (`msgtype` = ?) AND (`ext` = ?);";


NSString *kSQLRecentUpdateFromOrTo = @"UPDATE `tb_recent` SET "
                                        "`msgid` = ?,"
                                        "`from` = ?,"
                                        "`to` = ?,"
                                        "`msgtype` = ?,"
                                        "`content` = ?, "
                                        "`time` = ?,"
                                        "`badge` = ?,"
                                        "`ext` = ?"
                                        " WHERE "
                                        "(`from` = ? OR `to` = ?) AND `ext` = ?;";

NSString *kSQLRecentUpdateWithType = @"UPDATE `tb_recent` SET "
                                            "`msgid` = ?,"
                                            "`from` = ?,"
                                            "`to` = ?,"
                                            "`msgtype` = ?,"
                                            "`content` = ?, "
                                            "`time` = ?,"
                                            "`badge` = ?,"
                                            "`ext` = ?"
                                            " WHERE "
                                            "`msgtype` = ?";

NSString *kSQlRecentExistMsgId = @"SELECT * FROM `tb_recent` WHERE `msgid` = ?";


NSString *kSQLRecentGetChatMsgBage = @"SELECT `badge` FROM `tb_recent` WHERE (`from` = ? OR `to` = ?) AND `msgtype` = 196609 AND `ext` = ?;";

NSString *kSQLRecentChatMsgBadgeUpdate = @"UPDATE `tb_recent` SET "
                                          "`badge` = ?"
                                          " WHERE "
                                          "(`from` = ? OR `to` = ?) AND `msgtype` = 196609 AND ext = ?;";

NSString *kSQLRecentGrpNotifyBageUpdate = @"UPDATE `tb_recent` SET "
                                            "`badge` = ?"
                                            " WHERE "
                                            "`msgtype` = 200708;";

NSString *kSQLRecentMsgBadgeSum = @"SELECT SUM(`badge`) AS `sum` FROM `tb_recent`";

NSString *kSQLRecentDelMsgItemByMsgId = @"DELETE FROM `tb_recent` WHERE `msgid` = ?;";

NSString *kSQLRecentExsitMsgType = @"SELECT * FROM `tb_recent` WHERE `msgtype` = ?;";


NSString *kSQLRecentUpdateRosterItemAddReqBadge = @"UPDATE `tb_recent` SET `badge` = ? WHERE `msgtype` = ?";

NSString *kSQLRecentGetFirstBageWithMsgType = @"SELECT `badge` FROM `tb_recent` WHERE `msgtype` = ? LIMIT 1;";