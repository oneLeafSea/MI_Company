//
//  RosterTb.m
//  IM
//
//  Created by 郭志伟 on 14-12-25.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RosterTb.h"
#import "RosterConstants.h"
#import "RosterSql.h"
#import "Utils.h"
#import "FMDB.h"
#import "RosterConstants.h"

#import "LogLevel.h"

@interface RosterTb() {
    __weak FMDatabaseQueue *m_dq;
}
@end

@implementation RosterTb

- (instancetype)initWithUid:(NSString *)uid dbQueue:(FMDatabaseQueue *)dbq {
    if (self = [super init]) {
        m_dq = dbq;
        _uid = [uid copy];
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (instancetype) init {
    if (self = [super init]) {
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup {
    if (![self createTable]) {
        DDLogError(@"ERROR: creat %@ roster table!", self.uid);
    }
    return YES;
}


- (BOOL) createTable {
    
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    
    return ret;
}

- (BOOL) insertRoster:(Roster *)roster {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterInsert, roster.uid, roster.desc, roster.grp, roster.items, roster.ver];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (Roster *)getRoster {
    __block Roster *r = nil;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLRosterQueryByUid, self.uid];
        if ([rs next]) {
            r = [[Roster alloc] init];
            r.uid = [rs objectForColumnName:kRosterTableUid];
            r.desc = [rs objectForColumnName:kRosterTableDesc];
            r.grp = [rs objectForColumnName:kRosterTableGrp];
            r.items = [rs objectForColumnName:kRosterTableItems];
            r.ver = [rs objectForColumnName:kRosterTableVer];
        }
        [rs close];
    }];
    return r;
}

- (NSArray *)getAllRosters {
    __block NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:32];
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLRosterQuery];
        while ([rs next]) {
            Roster *r = [[Roster alloc] init];
            r.uid = [rs objectForColumnName:kRosterTableUid];
            r.desc = [rs objectForColumnName:kRosterTableDesc];
            r.grp = [rs objectForColumnName:kRosterTableGrp];
            r.items = [rs objectForColumnName:kRosterTableItems];
            r.ver = [rs objectForColumnName:kRosterTableVer];
            [arr addObject:r];
        }
        [rs close];
    }];
    return arr;
}


- (BOOL)updateRoster:(Roster *)roster {
    __block BOOL ret = YES;
    
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterUpdate, roster.uid, roster.desc, roster.grp, roster.items, roster.ver, roster.uid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)delRoster:(Roster *)roster {
    return YES;
}

@end
