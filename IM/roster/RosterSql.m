//
//  RosterSql.m
//  IM
//
//  Created by 郭志伟 on 14-12-25.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RosterSql.h"

// -----------------------------------------------------------------------------
// roster表

NSString *kSQLRosterCreate = @"CREATE TABLE IF NOT EXISTS `tb_roster` ( "
                                                            "`uid`	TEXT NOT NULL,"
                                                            "`desc`	TEXT,"
                                                            "`grp`	TEXT,"
                                                            "`items`	TEXT,"
                                                            "`ver`	TEXT,"
                                                            "PRIMARY KEY(uid)"
                                                            ");";

NSString *kSQLRosterInsert = @"INSERT INTO `tb_roster` (`uid`, `desc`, `grp`, `items`, `ver`) VALUES ("
                                                    "?,"
                                                    "?,"
                                                    "?,"
                                                    "?,"
                                                    "?"
                                                    ");";


NSString *kSQLRosterQueryByUid = @"SELECT * FROM tb_roster WHERE uid = ?";

NSString *kSQLRosterQuery = @"SELECT * FROM `tb_roster`";

NSString *kSQLRosterUpdate = @"UPDATE `tb_roster` SET "
                                "`uid` = ?, "
                                "`desc` = ?,"
                                "`grp` = ?,"
                                "`items` = ?,"
                                "`ver` = ?"
                                " WHERE "
                                "`uid` = ?;";

NSString *kSQLRosterDel = @"DELETE FROM `tb_roster` WHERE `uid` = ?;";

// -----------------------------------------------------------------------------
// tb_rosteritem_add_req 表
NSString *kSQLRosterItemAddReqCreate = @"CREATE TABLE IF NOT EXISTS tb_rosteritem_add_req ("
                                        "`msgid`	TEXT,"
                                        "`from`	TEXT,"
                                        "`to`	TEXT,"
                                        "`msg`	TEXT,"
                                        "`status`	INTEGER,"
                                        "`time`, TEXT,"
                                        "PRIMARY KEY(msgid)"
                                        ");";

NSString *kSQLRosterItemAddReqInsert =  @"INSERT INTO tb_rosteritem_add_req (`msgid`, `from`, `to`, `msg`, `status`, `time` ) VALUES ("
                                                        "?,"
                                                        "?,"
                                                        "?,"
                                                        "?,"
                                                        "?,"
                                                        "?"
                                                        ");";

NSString *kSQLRosterItemAddReqUpdate = @"UPDATE `tb_rosteritem_add_req` SET "
                                        "`msgid` = ?, "
                                        "`from` = ?,"
                                        "`to` = ?,"
                                        "`msg` = ?,"
                                        "`status` = ?,"
                                        "`time` = ?"
                                        " WHERE "
                                        "`msgid` = ?;";

NSString *kSQLRosterItemAddReqUpdateStatus = @"UPDATE `tb_rosteritem_add_req` SET "
                                            "`status` = ?,"
                                            "`time` = ?"
                                            " WHERE "
                                            "`msgid` = ?;";

NSString *kSQLRosterItemAddReqDel = @"DELETE FROM `tb_rosteritem_add_req` WHERE `msgid` = ?;";

NSString *kSQLRosterItemAddReqGetWithMsgid = @"SELECT * FROM `tb_rosteritem_add_req` WHERE `msgid` = ?;";

// -----------------------------------------------------------------------------
// tb_rosteritem_del_req 表

NSString *kSQLRosterItemDelReqCreate =  @"CREATE TABLE IF NOT EXISTS `tb_rosteritem_del_req` ("
                                             "`msgid`	TEXT,"
                                             "`from`	TEXT,"
                                             "`to`	TEXT,"
                                             "`status`	INTEGER,"
                                             "`time` TEXT,"
                                             "PRIMARY KEY(msgid)"
                                             ");";

NSString *kSQLRosterItemDelReqInsert = @"INSERT INTO tb_rosteritem_del_req (`msgid`, `from`, `to`, `status`, `time` ) VALUES ("
                                        "?,"
                                        "?,"
                                        "?,"
                                        "?,"
                                        "?"
                                        ");";

NSString *kSQLRosterItemDelReqUpdate = @"UPDATE `tb_rosteritem_del_req` SET "
                                            "`msgid` = ?, "
                                            "`from` = ?,"
                                            "`to` = ?,"
                                            "`status` = ?,"
                                            "`time` = ?"
                                            " WHERE "
                                            "`msgid` = ?;";

NSString *kSQLRosterItemDelReqUpdateStatus = @"UPDATE `tb_rosteritem_del_req` SET "
                                                "`status` = ?,"
                                                "`time` = ?"
                                                " WHERE "
                                                "`msgid` = ?;";


NSString *kSQLRosterItemDelReqDel = @"DELETE FROM tb_rosteritem_del_req WHERE msgid = ?;";

// -----------------------------------------------------------------------------
// roster_add_result 表

NSString *kSQLRosterItemAddResultCreate = @"CREATE TABLE  IF NOT EXISTS `tb_rosteritem_add_result` ("
                                            "`msgid`	TEXT,"
                                            "`from`	TEXT,"
                                            "`to`	INTEGER,"
                                            "`status`	INTEGER,"
                                            "`time`	TEXT,"
                                            "`gid`	INTEGER,"
                                            "`name`	INTEGER,"
                                            "PRIMARY KEY(msgid)"
                                            ");";

NSString *kSQLRosterItemAddResultInsert = @"INSERT INTO `tb_rosteritem_add_result` (`msgid`, `from`, `to`, `status`, `time`, `gid`, `name` ) VALUES ("
                                                "?,"
                                                "?,"
                                                "?,"
                                                "?,"
                                                "?,"
                                                "?,"
                                                "?"
                                                ");";
NSString *kSQLRosterItemAddResultUpdate = @"UPDATE tb_rosteritem_add_result SET "
                                            "`msgid` = ?, "
                                            "`from` = ?,"
                                            "`to` = ?,"
                                            "`status` = ?,"
                                            "`time` = ?,"
                                            "`gid` = ?,"
                                            "`name`	= ?,"
                                            " WHERE "
                                            "msgid = ?;";

NSString *kSQLRosterItemAddResultUpdateStatus = @"UPDATE `tb_rosteritem_add_result` SET "
                                                "`status` = ?,"
                                                "`time` = ?"
                                                " WHERE "
                                                "`msgid` = ?;";


NSString *kSQLRosterItemAddResultDel = @"DELETE FROM `tb_rosteritem_add_result` WHERE `msgid` = ?;";

