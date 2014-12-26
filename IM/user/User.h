//
//  User.h
//  IM
//
//  Created by 郭志伟 on 14-12-26.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RosterMgr.h"
#import "FMDB.h"


@interface User : NSObject

- (instancetype)initWithUid:(NSString *)uid;

@property(readonly) NSString  *uid;
@property(readonly) FMDatabaseQueue *dbq;
@property(readonly) RosterMgr *rosterMgr;

@end
