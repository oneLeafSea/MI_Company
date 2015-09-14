//
//  GroupChatNotificationTb.m
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatNotificationTb.h"
#import "GroupChatSql.h"
#import "GroupChatNoitificaiontCellModel.h"
#import "NSDate+Common.h"

@interface GroupChatNotificationTb()

@property(weak, nonatomic) FMDatabaseQueue *dbq;

@end

@implementation GroupChatNotificationTb

- (instancetype)initWithDbq:(FMDatabaseQueue *)dbq {
    if (self = [super init]) {
        self.dbq = dbq;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup {
    BOOL ret = YES;
    if (![self createTb]) {
        ret = NO;
    }
    return ret;
}

- (BOOL)createTb {
    __block BOOL ret = YES;
    [self.dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlGroupChatNotifyCreate];
    }];
    return ret;
}


- (BOOL)insertNotification:(GroupChatNotifyMsg *) msg fromname:(NSString *)fromname {
    
    if (![msg.notifytype isEqualToString:@"invent"]) {
        return NO;
    }
    
    GroupChatNoitificaiontCellModel *model = [[GroupChatNoitificaiontCellModel alloc] init];
    model.msgid = msg.qid;
    model.from = msg.from;
    model.to = msg.to;
    model.processed = NO;
    model.notifyType = msg.notifytype;
    if ([model.notifyType isEqualToString:@"invent"]) {
        model.content = [NSString stringWithFormat:@"%@邀请你加入%@群", fromname, msg.gname];
    }
    model.gid = msg.gid;
    model.gname = msg.gname;
    model.time = [[NSDate Now] formatWith:nil];
    
    __block BOOL ret = YES;
    [self.dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlGroupChatNotifyInsert, model.msgid, model.from, model.to, model.notifyType, model.content, model.gid, model.gname, [NSNumber numberWithBool:model.processed], model.time];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)updateNotificationProcessedWithGid:(NSString *)gid {
    __block BOOL ret = YES;
    [self.dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlGroupChatNotifyUpdate, @YES, gid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (NSArray *)getInvitationNotifcations {
    __block NSMutableArray *msgs = [[NSMutableArray alloc] initWithCapacity:64];
    [self.dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSqlGroupChatNotifyInvitation];
        while (rs.next) {
            GroupChatNoitificaiontCellModel *item = [[GroupChatNoitificaiontCellModel alloc] init];
            item.msgid = [rs objectForColumnName:@"msg_id"];
            item.from = [rs objectForColumnName:@"from"];
            item.to = [rs objectForColumnName:@"to"];
            item.notifyType = [rs objectForColumnName:@"notify_type"];
            item.content = [rs objectForColumnName:@"content"];
            item.time = [rs objectForColumnName:@"time"];
            item.gid = [rs objectForColumnName:@"gid"];
            item.gname = [rs objectForColumnName:@"gname"];
            NSNumber *p = [rs objectForColumnName:@"processed"];
            item.processed = [p boolValue];
            [msgs addObject:item];
        }
        [rs close];
    }];
    return msgs;
}

- (BOOL)clearDb {
    __block BOOL ret = YES;
    [self.dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlGroupChatNotifyClear];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

@end
