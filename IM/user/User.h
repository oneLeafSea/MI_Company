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
#import "PresenceMgr.h"
#import "AvatarMgr.h"
#import "GroupChatMgr.h"
#import "OsMgr.h"
#import "DetailMgr.h"
#import "WebRtcMgr.h"
#import "ChatMessageHistory.h"
#import "FCMgr.h"

@class ChatMessageHistory;

@interface User : NSObject

- (instancetype)initWithLoginresp:(LoginResp *)resp session:(Session *)session;

- (void)reset;

- (RosterItem *)getRosterInfoByUid:(NSString *)uid;

@property(readonly) NSString        *uid;
@property           NSString        *pwd;
@property(readonly) FMDatabaseQueue *dbq;
@property(readonly) RosterMgr       *rosterMgr;
@property(readonly) Session         *session;
@property(readonly) ChatMessageMgr  *msgMgr;
@property(readonly) RecentMgr       *recentMsg;
@property(readonly) FileTransfer    *fileTransfer;
@property(readonly) PresenceMgr     *presenceMgr;
@property(readonly) AvatarMgr       *avatarMgr;
@property(readonly) GroupChatMgr    *groupChatMgr;
@property(readonly) OsMgr           *osMgr;
@property(readonly) DetailMgr       *detailMgr;
@property(readonly) WebRtcMgr       *webRtcMgr;
@property(readonly) FCMgr           *fcMgr;
@property(readonly) ChatMessageHistory *msgHistory;


@property(readonly) NSDictionary    *cfg;

@property(nonatomic) Detail         *mineDetail;

@property(readonly) NSString *key;
@property(readonly) NSString *iv;
@property(readonly) NSString *token;
@property(readonly) NSString *name;
@property(readonly) NSString *org;
@property(readonly) NSString *orgName;
@property(nonatomic, strong) NSString *signature;

@property(readonly) NSString *imurl;
@property(readonly) NSString *fileDownloadSvcUrl;
@property(readonly) NSString *fileCompleteUrl;
@property(readonly) NSString *fileUploadSvcUrl;
@property(readonly) NSString *fileCheckUrl;
@property(readonly) NSString *fileUploadSvcUrl2;
@property(readonly) NSString *avatarUrl;
@property(readonly) NSString *avatarCheckUrl;
@property(readonly) NSString *rssUrl;
@property(readonly) NSString *iceUrl;
@property(readonly) NSString *fcImgServerUrl;
@property(readonly) NSString *fcImgThumbServerUrl;
@property(readonly) NSString *fcImgUploadUrl;
@property(readonly) NSString *imgThumbServerUrl;

@property(readonly) NSString *filePath;
@property(readonly) NSString *userPath;
@property(readonly) NSString *audioPath;
@property(readonly) NSString *avatarPath;



@property(atomic, readonly) BOOL kick;

@end
