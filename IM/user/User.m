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
#import "KickNotification.h"

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
    
    NSString *docPath = [Utils documentPath];
    _userPath = [docPath stringByAppendingPathComponent:_uid];
    BOOL ret = [Utils EnsureDirExists:_userPath];
    if (!ret) {
        DDLogError(@"ERROR: create user path.");
        return NO;
    }
    
    _filePath = [_userPath stringByAppendingPathComponent:@"files"];
    if (![Utils EnsureDirExists:_filePath]) {
        DDLogError(@"ERROR: create file path.");
        return NO;
    }
    
    _audioPath = [_userPath stringByAppendingString:@"audios"];
    if (![Utils EnsureDirExists:_audioPath]) {
        DDLogError(@"ERROR: create audios path");
        return NO;
    }
    
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
    
    if (![self setupRecentMgr]) {
        DDLogError(@"ERROR: setup recentMgr.");
        return NO;
    }
    
    _fileTransfer = [[FileTransfer alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKick:) name:kNotificationKick object:nil];
    
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

- (BOOL)setupRecentMgr {
    _recentMsg = [[RecentMgr alloc] initWithUid:self.uid dbq:self.dbq session:self.session];
    if (!_recentMsg) {
        return NO;
    }
    return YES;
}

- (void)reset {
    _session = nil;
    [self.rosterMgr reset];
    [self.msgMgr reset];
    [self.recentMsg reset];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationKick object:nil];
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
//218.4.226.210:48011
- (NSString *)imurl {
    return @"http://10.22.1.47:8040/";
//    return @"http://218.4.226.210:48011/";
}

- (NSString *)signature {
    return @"this is a signature";
}


- (void)handleKick:(NSNotification *) notification {
    _kick = YES;
}

- (NSString *)fileDownloadSvcUrl {
    return @"http://10.22.1.47:8040/file/download";
//    return @"http://218.4.226.210:48011/file/download";
}

- (NSString *)fileUploadSvcUrl {
    return @"http://10.22.1.47:8040/file/upload";
//    return @"http://218.4.226.210:48011/file/upload";
}

- (NSString *)fileCheckUrl {
   return @"http://10.22.1.47:8040/file/check";
//    return @"http://218.4.226.210:48011/file/check";
}

@end
