//
//  RosterVerTb.m
//  IM
//
//  Created by 郭志伟 on 15-1-19.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterVerTb.h"
#import "RosterSql.h"
#import "LogLevel.h"

@interface RosterVerTb() {
    FMDatabaseQueue *m_dq;
}

@end

@implementation RosterVerTb

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
        DDLogError(@"ERROR: create RosterVerTb");
        return NO;
    }
    return YES;
}

- (BOOL)createTb {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterVerCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

@end
