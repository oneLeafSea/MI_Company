//
//  OsOrgVerTb.m
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "OsOrgVerTb.h"
#import "LogLevel.h"
#import "OsSql.h"

@interface OsOrgVerTb() {
    __weak FMDatabaseQueue *m_dbq;
}
@end

@implementation OsOrgVerTb

- (instancetype)initWithDbq:(FMDatabaseQueue *)dbq {
    if (self = [super init]) {
        m_dbq = dbq;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}


- (BOOL)setup {
    if (![self createTb]) {
        DDLogError(@"ERROR: create tb_os_org_ver table.");
        return NO;
    }
    return YES;
}

- (BOOL)createTb {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlOsOrgVerCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    
    return ret;
}

- (NSString *)DbVer {
    __block NSString *ver = nil;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSqlOsOrgVerQuery];
        if (rs.next) {
            ver = [rs objectForColumnName:@"ver"];
        }
        [rs close];
    }];
    return ver;
}

- (BOOL)updateVer:(NSString *)ver {
    __block BOOL ret = YES;
    if (ver == nil) {
        return NO;
    }
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSqlOsOrgVerQuery];
        BOOL empty = NO;
        if (!rs.next) {
            empty = YES;
        }
        [rs close];
        if (empty) {
            ret = [db executeUpdate:kSqlOsOrgVerInsert, ver];
        } else {
            ret = [db executeUpdate:kSqlOsOrgVerUpdate, ver];
        }
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}


@end
