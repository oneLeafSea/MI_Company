//
//  ChatMessageTb.m
//  IM
//
//  Created by 郭志伟 on 15-1-16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageTb.h"
#import "ChatMessageSql.h"
#import "LogLevel.h"
#import "Utils.h"

@interface ChatMessageTb() {
    __weak FMDatabaseQueue *m_dbq;
}
@end

@implementation ChatMessageTb

- (instancetype)initWithDbQueue:(FMDatabaseQueue *)dbq {
    if (self = [super init]) {
        m_dbq = dbq;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL) setup {
    if (![self createTb]) {
        DDLogError(@"ERROR: creat roster table!");
    }
    return YES;
}

- (BOOL) createTb {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLChatMessageCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    
    return ret;
}

- (BOOL) updateWithMsgId:(NSString *)msgId status:(ChatMessageStatus) status {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLChatMessageUpdateStatus, [NSNumber numberWithUnsignedInt:status], msgId];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) updateSendingMsgToFail {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLChatMessageUpdateSendingMsgToFail, [NSNumber numberWithUnsignedInt:ChatMessageStatusSendError], [NSNumber numberWithUnsignedInt:ChatMessageStatusSending]];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}


- (BOOL) updateWithMsgId:(NSString *)msgId time:(NSString *)time {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLChatMessageUpdateTime, time, msgId];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) insertMessage:(ChatMessage *)msg {
    __block BOOL ret = YES;
    NSString *body = [[NSString alloc] initWithData:[Utils jsonDataFromDict:msg.body] encoding:NSUTF8StringEncoding];
    
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLChatMessageInsert, msg.qid, msg.from, msg.to, body, msg.time, [NSNumber numberWithUnsignedInt:msg.chatMsgType], msg.fromRes, msg.toRes, [NSNumber numberWithUnsignedInt:msg.status]];
    }];
    return ret;
}

- (BOOL) existMsgId:(NSString *)msgId {
    __block BOOL ret = NO;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLChatMessageExistMsgId, msgId];
        if (rs.next) {
            ret = YES;
        }
        [rs close];
    }];
    return ret;
}


- (NSArray *) getMsgsWithId:(NSString *)uid
                    msgType:(ChatMessageType) type
                      limit:(UInt32) limit
                     offset:(UInt32) offset {
    __block NSMutableArray *ret = [[NSMutableArray alloc] init];
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:KSQLChatMessageGetMsg, uid, uid, [NSNumber numberWithUnsignedInt:type], [NSNumber numberWithUnsignedInt:limit], [NSNumber numberWithUnsignedInt:offset]];
        while (rs.next) {
            ChatMessage *msg = [[ChatMessage alloc] init];
            msg.qid = [rs objectForColumnName:@"msgid"];
            msg.from = [rs objectForColumnName:@"from"];
            msg.to = [rs objectForColumnName:@"to"];
            NSString *body = [rs objectForColumnName:@"body"];
            NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
            msg.body = [[NSMutableDictionary alloc] initWithDictionary:[Utils dictFromJsonData:bodyData] copyItems:YES];
            msg.time = [rs objectForColumnName:@"time"];
            NSNumber *type = [rs objectForColumnName:@"type"];
            msg.chatMsgType = [type unsignedIntValue];
            msg.fromRes = [rs objectForColumnName:@"fromRes"];
            msg.toRes = [rs objectForColumnName:@"toRes"];
            NSNumber *status = [rs objectForColumnName:@"status"];
            msg.status = [status unsignedIntValue];
            [ret addObject:msg];
        }
        [rs close];
    }];
    return ret;
}

- (ChatMessage *)getLastGrpChatMsgByGid:(NSString *)gid {
    __block ChatMessage *ret = nil;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLChatMessageGetLastGrpChatMsg, gid];
        if (rs.next) {
            ChatMessage *msg = [[ChatMessage alloc] init];
            msg.qid = [rs objectForColumnName:@"msgid"];
            msg.from = [rs objectForColumnName:@"from"];
            msg.to = [rs objectForColumnName:@"to"];
            NSString *body = [rs objectForColumnName:@"body"];
            NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
            msg.body = [[NSMutableDictionary alloc] initWithDictionary:[Utils dictFromJsonData:bodyData] copyItems:YES];
            msg.time = [rs objectForColumnName:@"time"];
            NSNumber *type = [rs objectForColumnName:@"type"];
            msg.chatMsgType = [type unsignedIntValue];
            msg.fromRes = [rs objectForColumnName:@"fromRes"];
            msg.toRes = [rs objectForColumnName:@"toRes"];
            NSNumber *status = [rs objectForColumnName:@"status"];
            msg.status = [status unsignedIntValue];
            ret = msg;
        }
        [rs close];
    }];
    return ret;
}

- (ChatMessage *)getMsgByMsgId:(NSString *)msgId {
    __block ChatMessage *msg = nil;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLChatMessageGetMsgById, msgId];
        if (rs.next) {
            msg = [[ChatMessage alloc] init];
            msg.qid = [rs objectForColumnName:@"msgid"];
            msg.from = [rs objectForColumnName:@"from"];
            msg.to = [rs objectForColumnName:@"to"];
            NSString *body = [rs objectForColumnName:@"body"];
            NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
            msg.body = [[NSMutableDictionary alloc] initWithDictionary:[Utils dictFromJsonData:bodyData] copyItems:YES];
            msg.time = [rs objectForColumnName:@"time"];
            NSNumber *type = [rs objectForColumnName:@"type"];
            msg.chatMsgType = [type unsignedIntValue];
            msg.fromRes = [rs objectForColumnName:@"fromRes"];
            msg.toRes = [rs objectForColumnName:@"toRes"];
            NSNumber *status = [rs objectForColumnName:@"status"];
            msg.status = [status unsignedIntValue];
        }
        [rs close];
    }];
    return msg;
}


@end
