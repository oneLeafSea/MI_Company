//
//  AvatarTb.m
//  IM
//
//  Created by 郭志伟 on 15/9/2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "AvatarTb.h"
#import "AvatarSql.h"

@interface AvatarTb()

@property(weak) FMDatabaseQueue *dbq;

@end

@implementation AvatarTb

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
        ret = [db executeUpdate:kSqlAvatarTbCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)updateWithArray:(NSArray *)array {
    __block BOOL ret = YES;
    [self.dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dict = obj;
            NSString *uid = [dict objectForKey:@"userid"];
            NSString *ver = [dict objectForKey:@"avatar"];
            ret = [db executeUpdate:kSqlAvatarTbUpdate, uid, ver];
            if (!ret) {
                *rollback = YES;
                *stop = YES;
            }
        }];
        
    }];
    return ret;
}

- (BOOL)needUpdateForUid:(NSString *)uid {
    __block BOOL ret = NO;
    [self.dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSqlAvatarTbQueryById, uid];
        if (rs.next) {
            ret = YES;
        }
        [rs close];
    }];
    return ret;
}

- (void)updateAvatarSuccessWithUid:(NSString *)uid {
    [self.dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL ret = [db executeUpdate:kSqlAvatarTbUpdateSuccess, uid];
        if (!ret) {
            *rollback = YES;
        }
    }];
}

@end
