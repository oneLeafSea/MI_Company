//
//  RosterItemAcceptReqTb.m
//  IM
//
//  Created by 郭志伟 on 15-1-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemAddResultTb.h"
#import "LogLevel.h"
#import "RosterSql.h"
#import "NSDate+Common.h"


@interface RosterItemAddResultTb() {
    __weak FMDatabaseQueue *m_dq;
}
@end

@implementation RosterItemAddResultTb

- (instancetype)initWithDbQueue:(FMDatabaseQueue *) dbQueue {
    if (self = [super init]) {
        m_dq = dbQueue;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup {
    if (![self createTb]) {
        DDLogError(@"ERROR: create tb_rosteritem_add_result");
        return NO;
    }
    return YES;
}

- (BOOL)createTb {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemAddResultCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) insertResult:(RosterItemAddResult *)result {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemAddResultInsert, result.qid, result.from, result.to, [NSNumber numberWithUnsignedInt:result.status], [[NSDate Now] formatWith:nil], result.gid, result.name];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}


- (BOOL) updateResult:(RosterItemAddResult *)result {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemAddResultUpdate, result.qid, result.from, result.to, [NSNumber numberWithUnsignedInt:result.status], [[NSDate Now] formatWith:nil], result.gid, result.name, result.qid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) updateResultStatus:(RosterItemAddResultStatus)status MsgId:(NSString *)msgid {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemAddResultUpdateStatus, [NSNumber numberWithUnsignedInt:status], [[NSDate Now] formatWith:nil], msgid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) delResultWithMsgId:(NSString *)msgid {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemAddResultDel, msgid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (NSArray *)get {
    return nil;
}

@end
