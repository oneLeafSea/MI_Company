//
//  AvatarVerTb.m
//  IM
//
//  Created by 郭志伟 on 15/9/2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "AvatarVerTb.h"
#import "AvatarSql.h"

@interface AvatarVerTb()

@property(weak) FMDatabaseQueue *dbq;

@end

@implementation AvatarVerTb

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
    if (![self createTb]) {
        return NO;
    }
    return YES;
}


- (BOOL)createTb {
    __block BOOL ret = YES;
    [self.dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlAvatarVerTbCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)updateVersion:(NSString *)version {
    __block BOOL ret = YES;
    [self.dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlAvatarVerTbDel];
        if (!ret) {
            *rollback = YES;
        }
        ret = [db executeUpdate:kSqlAvatarVerTbUpdate, version];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (NSString *)getVersion {
    __block NSString *ver = @"0";
    [self.dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSqlAvatarVerQuery];
        if (rs.next) {
            ver = [rs objectForColumnName:@"ver"];
        }
        [rs close];
    }];
    return ver;
}

@end
