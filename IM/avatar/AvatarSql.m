//
//  AvatarSql.m
//  IM
//
//  Created by 郭志伟 on 15/9/2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "AvatarSql.h"

NSString *kSqlAvatarVerTbCreate = @"CREATE TABLE IF NOT EXISTS `tb_avatar_ver` (`ver`	TEXT, PRIMARY KEY(ver));";

NSString *kSqlAvatarVerTbUpdate = @"INSERT INTO `tb_avatar_ver`(`ver`) VALUES (?);";
NSString *kSqlAvatarVerQuery = @"SELECT `ver` FROM `tb_avatar_ver`;";

NSString *kSqlAvatarVerTbDel = @"DELETE FROM `tb_avatar_ver`;";


NSString *kSqlAvatarTbCreate = @"CREATE TABLE IF NOT EXISTS `tb_avatar` ("
                                "`uid`	TEXT,"
                                "`local_ver`	TEXT DEFAULT 0,"
                                "`svc_ver`	TEXT,"
                                "PRIMARY KEY(uid)"
                                ");";

NSString *kSqlAvatarTbUpdate = @"REPLACE INTO `tb_avatar`(`uid`, `local_ver`, `svc_ver`) VALUES(?, '0', ?)";

NSString *kSqlAvatarTbQueryById = @"SELECT * FROM `tb_avatar` WHERE `local_ver` != `svc_ver` AND `uid` = ?";

NSString *kSqlAvatarTbUpdateSuccess = @"UPDATE `tb_avatar` SET `local_ver` = `svc_ver` WHERE `uid` = ?;";