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
#import "IMConf.h"

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
    
    _audioPath = [_userPath stringByAppendingPathComponent:@"audios"];
    if (![Utils EnsureDirExists:_audioPath]) {
        DDLogError(@"ERROR: create audios path");
        return NO;
    }
    
    _avatarPath = [_userPath stringByAppendingPathComponent:@"avatars"];
    if (![Utils EnsureDirExists:_avatarPath]) {
        DDLogError(@"ERROR: create avatars path.");
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
    
    if (![self setupPresenceMgr]) {
        DDLogError(@"ERROR: setup presenceMgr.");
        return NO;
    }
    
    if (![self setupAvatarMgr]) {
        DDLogError(@"ERROR: setup AvatarMgr.");
        return NO;
    }
    
    if (![self setupGroupChatMgr]) {
        DDLogError(@"ERROR: setup groupMgr.");
        return NO;
    }
    
    if (![self setupOsMgr]) {
        DDLogError(@"ERROR: setup OsMgr.");
        return NO;
    }
    
    if (![self setupDetailMgr]) {
        DDLogError(@"ERROR: setup detailMgr.");
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

- (BOOL)setupPresenceMgr {
    _presenceMgr = [[PresenceMgr alloc] init];
    if (!_presenceMgr) {
        return NO;
    }
    return YES;
}

- (BOOL)setupAvatarMgr {
    _avatarMgr = [[AvatarMgr alloc] initWithAvatarPath:_avatarPath];
    if (!_avatarMgr) {
        return NO;
    }
    return YES;
}

- (BOOL)setupGroupChatMgr {
    _groupChatMgr = [[GroupChatMgr alloc] init];
    if (!_groupChatMgr) {
        return NO;
    }
    return YES;
}

- (BOOL)setupOsMgr {
    _osMgr = [[OsMgr alloc] initWithDbq:self.dbq];
    if (!_osMgr) {
        return NO;
    }
    return YES;
}

- (BOOL)setupDetailMgr {
    _detailMgr = [[DetailMgr alloc] init];
    if (!_detailMgr) {
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

- (NSString *)imurl {
    NSDictionary *services = [self.cfg objectForKey:@"services"];
    NSString *url = [services objectForKey:@"SVC_IM"];
    return url;
}

- (NSString *)avatarUrl {
    NSDictionary *services = [self.cfg objectForKey:@"services"];
    return [services objectForKey:@"SVC_FILE_DOWN_AVATAR"];
}

- (NSString *)avatarCheckUrl {
    NSDictionary *services = [self.cfg objectForKey:@"services"];
    NSString *url = [services objectForKey:@"SVC_AVATAR_CHECK"];
    return url;
}

- (NSString *)signature {
    return @"this is a signature";
}


- (void)handleKick:(NSNotification *) notification {
    _kick = YES;
}

- (NSString *)fileDownloadSvcUrl {
    NSDictionary *services = [self.cfg objectForKey:@"services"];
    return [services objectForKey:@"SVC_FILE_DOWN"];
}

- (NSString *)fileUploadSvcUrl {
    NSDictionary *services = [self.cfg objectForKey:@"services"];
    return [services objectForKey:@"SVC_FILE_UPLOAD"];
}

- (NSString *)fileCheckUrl {
    NSDictionary *services = [self.cfg objectForKey:@"services"];
    NSString *url = [services objectForKey:@"SVC_FILE_CHECK"];
    NSParameterAssert(url);
    return url;
}

@end
