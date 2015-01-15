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

- (instancetype)initWithLoginresp:(LoginResp *)resp session:(Session *)session {
    NSString *uid = [resp.respData objectForKey:@"user"];
    _session = session;
    if (self = [self initWithUid:uid]) {
        _cfg = [[NSDictionary alloc] initWithDictionary:resp.respData copyItems:YES];
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
    
    if (![self setupMsgMgr]) {
        DDLogError(@"ERROR: setup msgMgr.");
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
    DDLogInfo(@"INFO: userDb path: %@", dbPath);
    _dbq = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    if (!self.dbq) {
        DDLogError(@"ERROR: create dbq.");
        return NO;
    }
    return YES;
}

- (BOOL)setupRoster {
    _rosterMgr = [[RosterMgr alloc] initWithSelfId:self.uid dbq:self.dbq session:self.session];
    if (!_rosterMgr) {
        return NO;
    }
    return YES;
}

- (BOOL)setupMsgMgr {
    _msgMgr = [[ChatMessageMgr alloc] initWithSelfUid:self.uid dbq:self.dbq session:self.session];
    if (!_msgMgr) {
        return NO;
    }
    return YES;
}

- (void)reset {
    [self.rosterMgr reset];
}

- (NSString *)key {
    return [self.cfg objectForKey:@"key"];
}

- (NSString *)iv {
   return [self.cfg objectForKey:@"iv"];
}

- (NSString *)token {
    return [self.cfg objectForKey:@"token"];
}

- (NSString *)name {
    return [self.cfg objectForKey:@"name"];
}
@end
