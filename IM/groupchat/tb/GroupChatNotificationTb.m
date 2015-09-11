//
//  GroupChatNotificationTb.m
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatNotificationTb.h"
#import "GroupChatSql.h"

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

@end
