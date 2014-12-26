//
//  RosterSql.m
//  IM
//
//  Created by 郭志伟 on 14-12-25.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RosterSql.h"


NSString *kSQLRosterCreate = @"CREATE TABLE IF NOT EXISTS roster ( "
                                                            "uid	TEXT NOT NULL,"
                                                            "desc	TEXT,"
                                                            "grp	TEXT,"
                                                            "items	TEXT,"
                                                            "ver	TEXT,"
                                                            "PRIMARY KEY(uid)"
                                                            ");";

NSString *kSQLRosterInsert = @"INSERT INTO roster (uid, desc, grp, items, ver ) VALUES ("
                                                    "?,"
                                                    "?,"
                                                    "?,"
                                                    "?,"
                                                    "?"
                                                    ");";


NSString *kSQLRosterQueryByUid = @"SELECT * FROM roster WHERE uid = ?";

NSString *kSQLRosterQuery = @"SELECT * FROM roster";

NSString *kSQLRosterUpdate = @"UPDATE roster set "
                                "uid = ?, "
                                "desc = ?,"
                                "grp = ?,"
                                "items = ?,"
                                "ver = ?"
                                " WHERE "
                                "uid = ?;";

