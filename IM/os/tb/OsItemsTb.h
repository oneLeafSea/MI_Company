//
//  OsItemsTb.h
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "OsItem.h"

@interface OsItemsTb : NSObject

- (instancetype)initWithDbq:(FMDatabaseQueue *)dbq;


- (NSArray *)getItems;
- (BOOL)delAll;
- (BOOL)insertItem:(OsItem *) item;
- (BOOL)insertItemArray:(NSArray *)itemArray;
- (BOOL)updateItem:(OsItem *) item;
- (BOOL)deleteItem:(OsItem *) item;

- (NSArray *)getItemsByOrg:(NSString *)org;
- (OsItem *)getItemByUid:(NSString *)uid;

@end
