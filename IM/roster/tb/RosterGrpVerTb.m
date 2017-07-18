//
//  RosterGrpVerTb.m
//  IM
//
//  Created by 郭志伟 on 15-1-19.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterGrpVerTb.h"
#import "RosterSql.h"
#import "LogLevel.h"

@interface RosterGrpVerTb() {
    FMDatabaseQueue *m_dq;
}
@end

@implementation RosterGrpVerTb

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
        DDLogError(@"ERROR: create RosterGrpVerTb");
        return NO;
    }
    return YES;
}

- (BOOL)createTb {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterGrpVerCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

@end
