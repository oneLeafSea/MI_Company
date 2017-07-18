//
//  RosterDb.h
//  IM
//
//  Created by 郭志伟 on 14-12-25.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Roster.h"
#import "FMDB.h"

@interface RosterTb : NSObject

- (instancetype)initWithDbQueue:(FMDatabaseQueue *)dbq;

- (BOOL)refreshWithItems:(NSArray *)rosterItems;

- (BOOL)delItemWithUid:(NSString *)uid;

- (BOOL)delAll;

@end
