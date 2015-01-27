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
#import "RosterItem.h"

@interface RosterTb() {
    __weak FMDatabaseQueue *m_dq;
}
@end

@implementation RosterTb

- (instancetype)initWithDbQueue:(FMDatabaseQueue *)dbq {
    if (self = [super init]) {
        m_dq = dbq;
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
        DDLogError(@"ERROR: creat tb_roster table!");
        return NO;
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

- (BOOL)refreshWithItems:(NSArray *)rosterItems {
    
    if (![self delAll]) {
        return NO;
    }
    
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [rosterItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *item = obj;
            ret = [db executeUpdate:kSQLRosterInsert, [item objectForKey:@"fid"], [item objectForKey:@"fname"], [item objectForKey:@"gid"], [item objectForKey:@"sign"], [item objectForKey:@"avatar"]];
            if (!ret) {
                *rollback = YES;
                *stop = YES;
            }
        }];
        
    }];
    return ret;
}


- (BOOL)delItemWithUid:(NSString *)uid {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterDel, uid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)delAll {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterDelAll];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

@end
