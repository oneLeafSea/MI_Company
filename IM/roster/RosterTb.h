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

- (instancetype)initWithUid:(NSString *)uid dbQueue:(FMDatabaseQueue *)dbq;

//- (BOOL)insertRoster:(Roster *)roster;
//
//- (Roster *)getRoster;
//
//- (BOOL)updateRoster:(Roster *)roster;
//
//- (BOOL)delRoster:(Roster *)roster;

@property(copy, readonly) NSString* uid;

@end
