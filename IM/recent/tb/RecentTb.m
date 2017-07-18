//
//  RecentTb.m
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RecentTb.h"
#import "RecentSql.h"
#import "LogLevel.h"


@interface RecentTb() {
    __weak FMDatabaseQueue *m_dbq;
}

@end

@implementation RecentTb

- (instancetype) initWithDbq:(FMDatabaseQueue *)dbq {
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
        DDLogError(@"ERROR: create recent table.");
        return NO;
    }
    return YES;
}

- (BOOL) createTb {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRecentCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    
    return ret;
}

- (NSMutableArray *)loadMsgs {
    __block NSMutableArray *ret = [[NSMutableArray alloc] init];
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLRecentGetAll];
        while (rs.next) {
            RecentMsgItem *item = [[RecentMsgItem alloc] init];
            item.msgid = [rs objectForColumnName:@"msgid"];
            NSNumber *num = [rs objectForColumnName:@"msgtype"];
            item.msgtype = [num unsignedIntegerValue];
            item.content = [rs objectForColumnName:@"content"];
            item.time = [rs objectForColumnName:@"time"];
            item.from = [rs objectForColumnName:@"from"];
            item.to = [rs objectForColumnName:@"to"];
            item.ext = [rs objectForColumnName:@"ext"];
            id badge = [rs objectForColumnName:@"badge"];
            if (badge == [NSNull null]) {
                item.badge = @"0";
            } else {
                item.badge = badge;
            }
            [ret addObject:item];
        }
        [rs close];
    }];
    return ret;
}

- (BOOL) insertItem:(RecentMsgItem *)item {
    if (item == nil) {
        return NO;
    }
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRecentInsert, item.msgid, item.from, item.to, [NSNumber numberWithUnsignedInteger:item.msgtype], item.content, item.time, @"1", item.ext];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) exsitMsgFrom:(NSString *)from msgtype:(UInt32) type {
    __block BOOL ret = NO;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLRecentExsitFrom, from, [NSNumber numberWithUnsignedInt:type]];
        if (rs.next) {
            ret = YES;
        }
        [rs close];
    }];
    return ret;
}

- (BOOL) exsitMsgFromOrTo:(NSString *)fromTo msgtype:(UInt32)type ext:(NSString *)ext {
    __block BOOL ret = NO;
    if (ext == nil) {
        [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
            FMResultSet *rs = [db executeQuery:kSQLRecentExsitFromOrTo, fromTo, fromTo, [NSNumber numberWithUnsignedInt:type]];
            if (rs.next) {
                ret = YES;
            }
            [rs close];
        }];
    } else {
        [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
            FMResultSet *rs = [db executeQuery:kSQLRecentExsitFromOrToWithExt, fromTo, fromTo, [NSNumber numberWithUnsignedInt:type], ext];
            if (rs.next) {
                ret = YES;
            }
            [rs close];
        }];
    }
    
    return ret;
}

- (BOOL) exsitMsgFromOrTo:(NSString *)from to:(NSString *)to msgtype:(UInt32)type ext:(NSString *)ext {
    __block BOOL ret = NO;
    if (ext == nil) {
        [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
            FMResultSet *rs = [db executeQuery:kSQLRecentExsitFromOrTo, from, to, [NSNumber numberWithUnsignedInt:type]];
            if (rs.next) {
                ret = YES;
            }
            [rs close];
        }];
    } else {
        [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
            FMResultSet *rs = [db executeQuery:kSQLRecentExsitFromOrToWithExt2, from, to, to, from, [NSNumber numberWithUnsignedInt:type], ext];
            if (rs.next) {
                ret = YES;
            }
            [rs close];
        }];
    }
    
    return ret;
}

- (BOOL) updateItem:(RecentMsgItem *)item msgtype:(UInt32)type fromOrTo:(NSString *)fromOrTo {
    __block BOOL ret = NO;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRecentUpdateFromOrTo, item.msgid, item.from, item.to, [NSNumber numberWithUnsignedInteger:item.msgtype], item.content, item.time, item.badge, item.ext, fromOrTo, fromOrTo, item.ext];
    }];
    return ret;
}


- (BOOL) updateItem:(RecentMsgItem *)item msgtype:(UInt32)type from:(NSString *)from to:(NSString *)to {
    __block BOOL ret = NO;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRecentUpdateFromOrTo2, item.msgid, item.from, item.to, [NSNumber numberWithUnsignedInteger:item.msgtype], item.content, item.time, item.badge, item.ext, from, to, to, from, item.ext];
    }];
    return ret;
}


- (BOOL) updateItem:(RecentMsgItem *) item msgtyp:(UInt32)type {
    __block BOOL ret = NO;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRecentUpdateWithType, item.msgid, item.from, item.to, [NSNumber numberWithUnsignedInteger:item.msgtype], item.content, item.time, item.badge, item.ext, [NSNumber numberWithUnsignedInt:type]];
    }];
    return ret;
}

- (NSInteger) getChatMsgBadgeWithFromOrTo:(NSString *)fromOrTo chatMsgType:(NSString *)chatMsgType {
    __block NSInteger ret = -1;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLRecentGetChatMsgBage, fromOrTo, fromOrTo, chatMsgType];
        if (rs.next) {
            id badge = [rs objectForColumnName:@"badge"];
            if (badge == [NSNull null]) {
                ret = 0;
            } else {
                NSString *str = badge;
                ret = [str integerValue];
            }
            
        }
        [rs close];
    }];
    return ret;
}

- (BOOL) updateChatMsgBadge:(NSString *)badge fromOrTo:(NSString *) fromOrTo chatmsgType:(UInt32) chatMsgtype {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRecentChatMsgBadgeUpdate, badge, fromOrTo, fromOrTo, [NSString stringWithFormat:@"%d", (unsigned int)chatMsgtype]];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) updateChatMsgBadge:(NSString *)badge from:(NSString *)from to:(NSString *)to chatmsgType:(UInt32)chatMsgtype {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRecentChatMsgBadgeUpdate2, badge, from, to, [NSString stringWithFormat:@"%d", (unsigned int)chatMsgtype]];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

//- (BOOL) updateChatMsgBadge:(NSString *)badge fromOrTo:(NSString *)fromOrTo chatmsgType:(UInt32)chatMsgtype ext:(NSString *)ext {
//    __block BOOL ret = YES;
//    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        ret = [db executeUpdate:kSQLRecentChatMsgBadgeUpdate, badge, fromOrTo, fromOrTo, [NSString stringWithFormat:@"%d", (unsigned int)chatMsgtype]];
//        if (!ret) {
//            *rollback = YES;
//        }
//    }];
//    return ret;
//}

- (BOOL) updateRecentGrpNtifyBadge:(NSString *)badge {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRecentGrpNotifyBageUpdate, badge];
    }];
    return ret;
}

- (NSInteger) getMsgBadgeSum {
    __block NSInteger ret = 0;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLRecentMsgBadgeSum];
        if (rs.next) {
            id badge = [rs objectForColumnName:@"sum"];
            if (badge == [NSNull null]) {
                ret = 0;
            } else {
                NSString *str = badge;
                ret = [str integerValue];
            }
        }
        [rs close];
    }];
    return ret;
}

- (BOOL) delMsgItem:(RecentMsgItem *)item {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRecentDelMsgItemByMsgId, item.msgid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL) exsitmsgType:(UInt32) type {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLRecentExsitMsgType, [NSNumber numberWithUnsignedInt:type]];
        if (!rs.next) {
            ret = NO;
        }
        [rs close];
    }];
    return ret;
}


- (BOOL) exsitMsgId:(NSString *)msgId {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQlRecentExistMsgId, msgId];
        if (!rs.next) {
            ret = NO;
        }
        [rs close];
    }];
    return ret;
}

- (BOOL) updateRosterItemAddReqBadge:(NSString *)badge msgtype:(NSUInteger) msgtype {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSQLRecentUpdateRosterItemAddReqBadge, badge, [NSNumber numberWithInteger:msgtype]];
    }];
    return ret;
}

- (NSInteger) getFirstBadgeWithMsgType:(NSInteger) msgtype {
    __block NSInteger badge = 0;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSQLRecentGetFirstBageWithMsgType, [NSNumber numberWithInteger:msgtype]];
        if (rs.next) {
            NSNumber *b = [rs objectForColumnName:@"badge"];
            badge = [b integerValue];
        }
        [rs close];
    }];
    return badge;
}

@end
