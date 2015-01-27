//
//  RosterGrpTb.m
//  IM
//
//  Created by 郭志伟 on 15-1-19.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterGrpTb.h"
#import "RosterSql.h"

@interface RosterGrpTb() {
    __weak FMDatabaseQueue *m_dq;
}

@end

@implementation RosterGrpTb

- (instancetype)initWithDbQueue:(FMDatabaseQueue *)dbq {
    if (self = [super init]) {
        m_dq = dbq;
        if (![self setup]) {
            self = nil;
        }
    }
    
    return self;
}

- (BOOL)setup {
    if (![self createTb]) {
        return NO;
    }
    return YES;
}

- (BOOL)createTb {
    
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterGrpCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    
    return ret;
}

- (BOOL)refreshGrpWithArray:(NSArray *)grp {
    if (![self delAll]) {
        return NO;
    }
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [grp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *grpItem = obj;
            NSString *gid = [grpItem objectForKey:@"gid"];
            NSString *name = [grpItem objectForKey:@"n"];
            NSNumber *defaultGrp = [grpItem objectForKey:@"def"] ? @1 : @0;
            ret = [db executeUpdate:kSQLRosterGrpInsert, gid, name, defaultGrp];
            if (!ret) {
                *stop = YES;
                *rollback = YES;
            }
        }];
    }];
    return ret;
    
}

- (BOOL)updateGrpName:(NSString *)name gid:(NSString *)gid {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterUpdate, gid, name];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return YES;
}


- (BOOL)insertGrpWithGid:(NSString *)gid gname:(NSString *)gname {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterGrpInsert, gid, gname];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
    
}

- (BOOL)delAll {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterGrpDelAll];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)delGrpWithId:(NSString *)gid {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterGrpDelWithGid, gid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

@end
