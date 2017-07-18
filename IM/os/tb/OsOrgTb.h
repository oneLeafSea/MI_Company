//
//  OsOrgTb.h
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "OsOrg.h"

@interface OsOrgTb : NSObject

- (instancetype)initWithDbq:(FMDatabaseQueue *)dbq;

- (NSArray *)getOrg;

- (BOOL)delAll;

- (BOOL)insertOrg:(OsOrg *) org;

- (BOOL)insertOrgArray:(NSArray *)orgArray;

- (NSArray *)getSubOrgByJgbm:(NSString *)jgbm;
- (OsOrg *)getRootOrg;

@end
