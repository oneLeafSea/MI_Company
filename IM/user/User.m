//
//  User.m
//  IM
//
//  Created by 郭志伟 on 14-12-26.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "User.h"
#import "Utils.h"
#import "UserConstants.h"
#import "LogLevel.h"

@implementation User

- (instancetype)initWithUid:(NSString *)uid {
    if (self = [super init]) {
        _uid = [uid copy];
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup {
    if (![self setupDb]) {
        DDLogError(@"ERROR: setup database");
        return NO;
    }
    
    if (![self setupRoster]) {
        DDLogError(@"ERROR: setup Roster");
        return NO;
    }
    return YES;
}

- (BOOL)setupDb {
    NSString *docDir = [Utils documentPath];
    NSString *userDir = [docDir stringByAppendingPathComponent:self.uid];
    if (![Utils EnsureDirExists:userDir]) {
        DDLogError(@"ERROR: create user directory error.");
        return NO;
    }
    NSString *dbPath = [userDir stringByAppendingPathComponent:kUserDbName];
    _dbq = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    if (!self.dbq) {
        DDLogError(@"ERROR: create dbq.");
        return NO;
    }
    return YES;
}

- (BOOL)setupRoster {
    RosterMgr *rm = [[RosterMgr alloc] initWithSelfId:self.uid dbq:self.dbq];
    if (!rm) {
        return NO;
    }
    return YES;
}


@end
