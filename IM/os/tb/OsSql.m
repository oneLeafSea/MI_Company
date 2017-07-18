//
//  OsSql.m
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "OsSql.h"

#pragma mark - org
NSString *kSqlOsOrgCreate = @"CREATE TABLE IF NOT EXISTS `tb_os_org` ("
                            "`jgbm`	TEXT,"
                            "`jgmc`	TEXT NOT NULL,"
                            "`jgjc`	TEXT,"
                            "`sjjgbm`	TEXT,"
                            "`xh`	TEXT,"
                            "PRIMARY KEY(jgbm)"
                            ");";
NSString *kSqlOsOrgQuery = @"SELECT * FROM `tb_os_org`;";
NSString *kSqlOsOrgDel   = @"DELETE FROM `tb_os_org`;";
NSString *kSqlOsOrgInsert = @"INSERT INTO `tb_os_org` (`jgbm`, `jgmc`, `jgjc`, `sjjgbm`, `xh`)  VALUES (?, ?, ?, ?, ?);";
NSString *kSqlOsOrgQueryByJgbm = @"SELECT * FROM `tb_os_org` WHERE `sjjgbm` = ? ORDER BY `xh`;";
NSString *kSqlOsOrgQueryRoot = @"SELECT * FROM `tb_os_org`  WHERE `sjjgbm` is null;";


#pragma mark - org version
NSString *kSqlOsOrgVerCreate = @"CREATE TABLE IF NOT EXISTS `tb_os_org_ver` ("
                                    "`ver`	TEXT,"
                                    "PRIMARY KEY(ver)"
                                    ");";
NSString *kSqlOsOrgVerQuery = @"SELECT * FROM  `tb_os_org_ver`";

NSString *kSqlOsOrgVerUpdate = @"UPDATE `tb_os_org_ver` SET `ver` = ?";

NSString *kSqlOsOrgVerInsert = @"INSERT INTO `tb_os_org_ver` (`ver`) VALUES(?)";


#pragma mark - org items.
NSString *kSqlOsItemsCreate = @"CREATE TABLE IF NOT EXISTS `tb_os_items` ("
                                        "`uid`	TEXT,"
                                        "`name`	TEXT,"
                                        "`org`	TEXT,"
                                        "PRIMARY KEY(uid)"
                                        ");";
NSString *kSqlOsItemsDel = @"DELETE FROM `tb_os_items` WHERE `uid` = ?;";
NSString *kSqlOsItemsQuery = @"SELECT * FROM `tb_os_items`;";
NSString *kSqlOsItemsQueryByOrg = @"SELECT * FROM `tb_os_items` WHERE `org` = ?;";
NSString *kSqlOsItemsQueryByUid = @"SELECT * FROM `tb_os_items` WHERE `uid` = ?;";
NSString *kSqlOsItemsInsert = @"INSERT INTO `tb_os_items` (`uid`, `name`, `org`)  VALUES (?, ?, ?);";
NSString *kSqlOsItemsUpdate = @"UPDATE `tb_os_items` SET "
                                    "`uid` = ?,"
                                    "`name` = ?,"
                                    "`org` = ?"
                                    " WHERE "
                                    "`uid` = ?;";
NSString *kSqlOsItemDel = @"DELETE FROM `tb_os_items` WHERE `uid` = ?;";


#pragma mark - org items ver.
NSString *kSqlOsitemsVerCreate = @"CREATE TABLE IF NOT EXISTS `tb_os_items_ver` ("
                                        "`ver`	TEXT"
                                        ");";

NSString *kSqlOsitemsVerQuery = @"SELECT * FROM  `tb_os_items_ver`";

NSString *kSqlOsitemsVerUpdate = @"UPDATE `tb_os_items_ver` SET `ver` = ?";

NSString *kSqlOsitemsVerInsert = @"INSERT INTO `tb_os_items_ver` (`ver`) VALUES(?)";
