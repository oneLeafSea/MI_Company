//
//  RosterItemAddReqTb.m
//  IM
//
//  Created by 郭志伟 on 15-1-5.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemAddReqTb.h"
#import "RosterSql.h"
#import "LogLevel.h"
#import "NSDate+Common.h"

@interface RosterItemAddReqTb() {
    __weak FMDatabaseQueue *m_dq;
}
@end

@implementation RosterItemAddReqTb

- (instancetype)initWithdbQueue:(FMDatabaseQueue *)dbq;
{
    self = [super init];
    if (self) {
        m_dq = dbq;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup {
    if (![self createTable]) {
        DDLogError(@"ERROR: create rosteritem add request table.");
        return NO;
    }
    return YES;
}

- (BOOL)createTable {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemAddReqCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    
    return ret;
}

- (BOOL) insertReq:(RosterItemAddRequest *)req {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemAddReqInsert, req.qid, req.from, req.to, req.msg, [NSNumber numberWithUnsignedInt:req.status], req.time];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) updateReq:(RosterItemAddRequest *)req {
    __block BOOL ret = YES;
    
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemAddReqUpdate, req.qid, req.from, req.to, req.msg, [NSNumber numberWithUnsignedInt:req.status], req.time, req.qid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) updateReqStatus:(RosterItemAddReqStatus)reqStatus from:(NSString *)from {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemUpdateReqStatusByFrom, [NSNumber numberWithInteger:reqStatus], from];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}


- (BOOL) updateReqStatusWithMsgid:(NSString *)msgid status:(RosterItemAddReqStatus) status {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemAddReqUpdateStatus, [NSNumber numberWithUnsignedInt:status], [[NSDate Now] formatWith:nil], msgid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) delReq:(RosterItemAddRequest *)req {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRosterItemAddReqDel, req.qid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (RosterItemAddRequest *) getReqWithMsgId:(NSString *)msgid {
    
    __block RosterItemAddRequest *r = nil;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLRosterItemAddReqGetWithMsgid, msgid];
        if ([rs next]) {
            NSString *msgid = [rs objectForColumnName:@"msgid"];
            NSString *from = [rs objectForColumnName:@"from"];
            NSString *to = [rs objectForColumnName:@"to"];
            NSString *msg = [rs objectForColumnName:@"msg"];
            NSNumber *status = [rs objectForColumnName:@"status"];
            NSString *time = [rs objectForColumnName:@"time"];
            r = [[RosterItemAddRequest alloc] initWithFrom:from to:to msgid:msgid msg:msg status:status time:time];
        }
        [rs close];
    }];
    return r;
}

- (NSArray *) getAllRosterItemReqButMe: (NSString *)me {
    __block NSMutableArray *ret = [[NSMutableArray alloc] init];
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLRosterItemAddReqGetAllButMe, me];
        while (rs.next) {
            NSString *msgid = [rs objectForColumnName:@"msgid"];
            NSString *from = [rs objectForColumnName:@"from"];
            NSString *to = [rs objectForColumnName:@"to"];
            NSString *msg = [rs objectForColumnName:@"msg"];
            NSNumber *status = [rs objectForColumnName:@"status"];
            NSString *time = [rs objectForColumnName:@"time"];
            RosterItemAddRequest *r = [[RosterItemAddRequest alloc] initWithFrom:from to:to msgid:msgid msg:msg status:status time:time];
            [ret addObject:r];
        }
    }];
    return ret;
}

- (BOOL) delAll {
    __block BOOL ret = YES;
    [m_dq inTransaction:^(FMDatabase *db, BOOL *rollback) {
       ret = [db executeUpdate:kSQLRosterItemAddReqDelAll];
    }];
    return ret;
}

@end
