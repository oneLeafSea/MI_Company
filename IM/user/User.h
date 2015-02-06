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
#import "LoginResp.h"
#import "session.h"
#import "ChatMessageMgr.h"
#import "RecentMgr.h"
#import "FileTransfer.h"


@interface User : NSObject

//- (instancetype)initWithUid:(NSString *)uid;

- (instancetype)initWithLoginresp:(LoginResp *)resp session:(Session *)session;

- (void)reset;

@property(readonly) NSString        *uid;
@property(readonly) FMDatabaseQueue *dbq;
@property(readonly) RosterMgr       *rosterMgr;
@property(readonly) Session         *session;
@property(readonly) ChatMessageMgr  *msgMgr;
@property(readonly) RecentMgr       *recentMsg;
@property(readonly) FileTransfer    *fileTransfer;

@property(readonly) NSDictionary    *cfg;

@property(readonly) NSString *key;
@property(readonly) NSString *iv;
@property(readonly) NSString *token;
@property(readonly) NSString *name;
@property(readonly) NSString *signature;

@property(readonly) NSString *imurl;
@property(readonly) NSString *fileDownloadSvcUrl;
@property(readonly) NSString *fileUploadSvcUrl;
@property(readonly) NSString *fileCheckUrl;

@property(readonly) NSString *filePath;
@property(readonly) NSString *userPath;



@property(atomic, readonly) BOOL kick;

@end
