//
//  OsOrgTb.m
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "OsOrgTb.h"
#import "OsSql.h"
#import "LogLevel.h"
#import "OsItem.h"


@interface OsOrgTb() {
    __weak FMDatabaseQueue *m_dbq;
}
@end

@implementation OsOrgTb

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
        DDLogError(@"ERROR: create tb_os_org table.");
        return NO;
    }
    return YES;
}


- (BOOL)createTb {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlOsOrgCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (NSArray *)getOrg {
    __block NSMutableArray *org = [[NSMutableArray alloc] init];
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSqlOsOrgQuery];
        while (rs.next) {
            NSString *jgbm = [rs objectForColumnName:@"jgbm"];
            NSString *jgmc = [rs objectForColumnName:@"jgmc"];
            NSString *jgjc = [rs objectForColumnName:@"jgjc"];
            if ([jgjc isKindOfClass:[NSNull class]]) {
                jgjc = nil;
            }
            NSString *sjjgbm = [rs objectForColumnName:@"sjjgbm"];
            if ([sjjgbm isKindOfClass:[NSNull class]]) {
                sjjgbm = nil;
            }
            NSString *xh = [rs objectForColumnName:@"xh"];
            OsOrg *o = [[OsOrg alloc] initWithJgbm:jgbm jgmc:jgmc jgjc:jgjc sjjgbm:sjjgbm xh:xh];
            [org addObject:o];
        }
        [rs close];
    }];
    return org;
}

- (BOOL)delAll {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlOsOrgDel];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)insertOrg:(OsOrg *) org {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlOsOrgInsert, org.jgbm, org.jgmc, org.jgjc, org.sjjgbm, org.xh];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)insertOrgArray:(NSArray *)orgArray {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [orgArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            OsOrg *org = obj;
            ret = [db executeUpdate:kSqlOsOrgInsert, org.jgbm, org.jgmc, org.jgjc, org.sjjgbm, org.xh];
            if (!ret) {
                *rollback = YES;
                *stop = YES;
            }
        }];
    }];
    return ret;
}

- (NSArray *)getSubOrgByJgbm:(NSString *)jgbm {
    NSMutableArray *orgs = [[NSMutableArray alloc] init];
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSqlOsOrgQueryByJgbm, jgbm];
        while (rs.next) {
            NSString *jgbm = [rs objectForColumnName:@"jgbm"];
            NSString *jgmc = [rs objectForColumnName:@"jgmc"];
            NSString *jgjc = [rs objectForColumnName:@"jgjc"];
            if ([jgjc isKindOfClass:[NSNull class]]) {
                jgjc = nil;
            }
            NSString *sjjgbm = [rs objectForColumnName:@"sjjgbm"];
            if ([sjjgbm isKindOfClass:[NSNull class]]) {
                sjjgbm = nil;
            }
            NSString *xh = [rs objectForColumnName:@"xh"];
            OsOrg *o = [[OsOrg alloc] initWithJgbm:jgbm jgmc:jgmc jgjc:jgjc sjjgbm:sjjgbm xh:xh];
            NSLog(@"---OsOrg-%@%@%@%@%@----->",jgbm,jgmc,jgjc,sjjgbm,xh);
            [orgs addObject:o];
        }
        [rs close];
    }];
    return orgs;
}

- (OsOrg *)getRootOrg {
    __block OsOrg *rootOrg = nil;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSqlOsOrgQueryRoot];
        if (rs.next) {
            NSString *jgbm = [rs objectForColumnName:@"jgbm"];
            NSString *jgmc = [rs objectForColumnName:@"jgmc"];
            NSString *jgjc = [rs objectForColumnName:@"jgjc"];
            if ([jgjc isKindOfClass:[NSNull class]]) {
                jgjc = nil;
            }
            NSString *sjjgbm = [rs objectForColumnName:@"sjjgbm"];
            if ([sjjgbm isKindOfClass:[NSNull class]]) {
                sjjgbm = nil;
            }
            NSString *xh = [rs objectForColumnName:@"xh"];
            rootOrg = [[OsOrg alloc] initWithJgbm:jgbm jgmc:jgmc jgjc:jgjc sjjgbm:sjjgbm xh:xh];
        }
        [rs close];
    }];
    return rootOrg;
}

@end
