//
//  RosterItemDelReqTb.m
//  IM
//
//  Created by 郭志伟 on 15-1-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemDelReqTb.h"
#import "RosterSql.h"
#import "LogLevel.h"
#import "NSDate+Common.h"

@interface RosterItemDelReqTb() {
    __weak FMDatabaseQueue *m_dq;
}

@end

@implementation RosterItemDelReqTb

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
        DDLogError(@"ERROR: create RosterItemDelReqTb");
        return NO;
    }
    return YES;
}

- (BOOL)createTb {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemDelReqCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) insertReq:(RosterItemDelRequest *)req {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemDelReqInsert, req.qid, req.from, req.to, [NSNumber numberWithUnsignedInt:req.status], [[NSDate Now] formatWith:nil]];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) updateReq:(RosterItemDelRequest *)req {
    __block BOOL ret = YES;
    
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemDelReqUpdate, req.qid, req.from, req.to, [NSNumber numberWithUnsignedInt:req.status], [[NSDate Now] formatWith:nil], req.qid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) updateReqStatus:(RosterItemDelRequestStatus)status MsgId:(NSString *)msgid {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemAddReqUpdateStatus, [NSNumber numberWithUnsignedInt:status], [[NSDate Now] formatWith:nil], msgid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) delReqWithMsgId:(NSString *)msgid {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeQuery:kSQLRosterItemDelReqDel, msgid];
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
