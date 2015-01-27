//
//  RosterGrpTb.h
//  IM
//
//  Created by 郭志伟 on 15-1-19.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface RosterGrpTb : NSObject

- (instancetype)initWithDbQueue:(FMDatabaseQueue *)dbq;

- (BOOL)refreshGrpWithArray:(NSArray *)grp;

- (BOOL)updateGrpName:(NSString *)name gid:(NSString *)gid;

- (BOOL)insertGrpWithGid:(NSString *)gid gname:(NSString *)gname;

- (BOOL)delAll;

- (BOOL)delGrpWithId:(NSString *)gid;

@end
