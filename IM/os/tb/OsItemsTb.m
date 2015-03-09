//
//  OsItemsTb.m
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "OsItemsTb.h"
#import "LogLevel.h"
#import "OsSql.h"
#import "OsItem.h"

@interface OsItemsTb() {
    __weak FMDatabaseQueue *m_dbq;
}
@end

@implementation OsItemsTb

- (instancetype)initWithDbq:(FMDatabaseQueue *)dbq {
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
        DDLogError(@"ERROR: create tb_os_items table.");
        return NO;
    }
    return YES;
}

- (BOOL)createTb {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlOsItemsCreate];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)delAll {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlOsItemsDel];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)insertItem:(OsItem *) item {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlOsItemsInsert, item.uid, item.name, item.org];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)insertItemArray:(NSArray *)itemArray {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [itemArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            OsItem *item = obj;
            ret = [db executeUpdate:kSqlOsItemsInsert, item.uid, item.name, item.org];
            if (!ret) {
                *rollback = YES;
                *stop = YES;
            }
        }];
    }];
    return ret;
}

- (BOOL)updateItem:(OsItem *) item {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlOsItemsUpdate, item.uid, item.name, item.org, item.uid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (BOOL)deleteItem:(OsItem *) item {
    __block BOOL ret = YES;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:kSqlOsItemsDel, item.uid];
        if (!ret) {
            *rollback = YES;
        }
    }];
    return ret;
}

- (NSArray *)getItems {
    __block NSMutableArray *items = [[NSMutableArray alloc] init];
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSqlOsItemsQuery];
        while (rs.next) {
            NSString *uid = [rs objectForColumnName:@"uid"];
            NSString *name = [rs objectForColumnName:@"name"];
            NSString *org = [rs objectForColumnName:@"org"];
            OsItem *item = [[OsItem alloc] initWithUid:uid name:name org:org];
            [items addObject:item];
        }
        [rs close];
    }];
    return items;
}

- (NSArray *)getItemsByOrg:(NSString *)org {
    __block NSMutableArray *items = [[NSMutableArray alloc] init];
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSqlOsItemsQueryByOrg, org];
        while (rs.next) {
            NSString *uid = [rs objectForColumnName:@"uid"];
            NSString *name = [rs objectForColumnName:@"name"];
            NSString *org = [rs objectForColumnName:@"org"];
            OsItem *item = [[OsItem alloc] initWithUid:uid name:name org:org];
            [items addObject:item];
        }
        [rs close];
    }];
    return items;
}

- (OsItem *)getItemByUid:(NSString *)uid {
    __block OsItem *item = nil;
    [m_dbq inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:kSqlOsItemsQueryByUid, uid];
        if (rs.next) {
            NSString *uid = [rs objectForColumnName:@"uid"];
            NSString *name = [rs objectForColumnName:@"name"];
            NSString *org = [rs objectForColumnName:@"org"];
            item = [[OsItem alloc] initWithUid:uid name:name org:org];
        }
        [rs close];
    }];
    return item;
}

@end
