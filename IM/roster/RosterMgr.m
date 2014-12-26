//
//  rosterMgr.m
//  IM
//
//  Created by 郭志伟 on 14-12-17.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "rosterMgr.h"
#import "RosterTb.h"


@interface RosterMgr() <RequestDelegate> {
    NSString *m_sid;                // 用户的id
    RosterTb *m_tb;                 // 用户表
    __weak FMDatabaseQueue *m_dbq;  // 数据库
}

@end

@implementation RosterMgr

- (instancetype)initWithSelfId:(NSString *)sid dbq:(FMDatabaseQueue *)dbq {
    if (self = [super init]) {
        m_sid = sid;
        if (![self setup]) {
            self  = nil;
        }
    }
    return self;
}


- (BOOL)setup {
    if (![self setupTb]) {
        return NO;
    }
    return YES;
}

- (BOOL)setupTb {
    m_tb = [[RosterTb alloc] initWithUid:m_sid dbQueue:m_dbq];
    if (!m_tb) {
        return NO;
    }
    return YES;
}

- (void)addItemWithTo:(NSString *)to
              groupId:(NSString *)gid
               reqmsg:(NSString *)reqmsg
              session:(Session *)session {
    RosterItemAddRequest *req = [[RosterItemAddRequest alloc] initWithFrom:m_sid to:to groupId:gid reqmsg:reqmsg];
    [session post:req];
}

- (void)acceptRosterItemId:(NSString *)uid
                    grouId:(NSString *)gid
                    accept:(BOOL) accept
                   session:(Session *)session {
    RosterItemAddResult *result = [[RosterItemAddResult alloc] initWithFrom:m_sid to:uid gid:gid];
    result.accept = accept;
    [session post:result];
}

- (void)delItemWithUid:(NSString *)uid session:(Session *)session {
    
}

- (void)getWithSession:(Session *)session {
    
}

- (NSString *)version {
    return @"1.0";
}

#pragma mark - RequestDelegate

- (void)request:(Request *)req response:(Response *)resp {
    
}

- (void)request:(Request *)req error:(NSError *)error {
    
}

@end
