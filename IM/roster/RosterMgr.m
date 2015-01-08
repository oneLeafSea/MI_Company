//
//  rosterMgr.m
//  IM
//
//  Created by 郭志伟 on 14-12-17.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "rosterMgr.h"

#import "Utils.h"
#import "LogLevel.h"

#import "IMAck.h"
#import "RosterNotification.h"
#import "RosterItemAddResult.h"
#import "RosterItemDelRequest.h"
#import "MessageConstants.h"

#import "RosterTb.h"
#import "RosterItemDelReqTb.h"
#import "RosterItemAddReqTb.h"
#import "RosterItemAddResultTb.h"

#import "Roster.h"
#import "JRSession.h"
#import "JRTextResponse.h"
#import "NSUUID+StringUUID.h"

#import "RosterQid.h"


@interface RosterMgr() {
    NSString                *m_sid;                // 用户的id
    RosterTb                *m_rosterTb;           // 用户表
    RosterItemAddReqTb      *m_rosterAddTb;
    RosterItemDelReqTb      *m_rosterDelTb;
    RosterItemAddResultTb   *m_rosterAddResultTb;
    __weak FMDatabaseQueue  *m_dbq;                // 数据库
    NSString                *m_ver;                // 版本号
    __weak  Session         *m_session;
    Roster                  *m_roster;
}

@end

@implementation RosterMgr

- (instancetype)initWithSelfId:(NSString *)sid dbq:(FMDatabaseQueue *)dbq session:(Session *)session{
    if (self = [super init]) {
        m_sid = sid;
        m_dbq = dbq;
        m_session = session;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIMAck:) name:kIMAckNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRosterItemAddReq:) name:kRosterItemAddRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRosterItemAddNotify:) name:kRosterItemAddNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRosterItemDelNotify:) name:kRosterItemDelNotification object:nil];
    return YES;
}

- (BOOL)setupTb {
    m_rosterTb = [[RosterTb alloc] initWithUid:m_sid dbQueue:m_dbq];
    if (!m_rosterTb) {
        return NO;
    }
    
    m_rosterAddTb = [[RosterItemAddReqTb alloc] initWithdbQueue:m_dbq];
    if (!m_rosterAddTb) {
        return NO;
    }
    
    m_rosterDelTb = [[RosterItemDelReqTb alloc] initWithDbQueue:m_dbq];
    if (!m_rosterDelTb) {
        return NO;
    }
    
    m_rosterAddResultTb = [[RosterItemAddResultTb alloc] initWithDbQueue:m_dbq];
    if (!m_rosterAddResultTb) {
        return NO;
    }
    
    return YES;
}

- (BOOL)addItemWithTo:(NSString *)to
              groupId:(NSString *)gid
               reqmsg:(NSString *)reqmsg
             selfName:(NSString *)selfName {
    RosterItemAddRequest *req = [[RosterItemAddRequest alloc] initWithFrom:m_sid to:to groupId:gid reqmsg:reqmsg selfName:selfName];
    req.status = RosterItemAddReqStatusRequesting;
    BOOL ret = [m_rosterAddTb insertReq:req];
    if (ret) {
        [m_session post:req];
    }
    return ret;
}

//- (BOOL)acceptRosterItemId:(NSString *)uid
//                    grouId:(NSString *)gid
//                      name:(NSString *)name
//                       msg:(NSString *)msg
//                    accept:(BOOL) accept {
//    RosterItemAddResult *result = [[RosterItemAddResult alloc] initWithFrom:m_sid to:uid gid:gid name:name msg:msg];
//    result.accept = accept;
//    result.status = RosterItemDelRequestRequesting;
//    if ([m_rosterAddResultTb insertResult:result]) {
//        [m_session post:result];
//    } else {
//        return NO;
//    }
//    return YES;
//}

- (BOOL)acceptRosterItemWithMsgid:(NSString *)msgid
                          groupId:(NSString *)gid
                             name:(NSString *)name
                           accept:(BOOL)accept {
#warning "这个函数没有测试！"
    RosterItemAddRequest *req = [m_rosterAddTb getReqWithMsgId:msgid];
    RosterItemAddResult *result = [[RosterItemAddResult alloc] initWithFrom:m_sid to:req.to gid:gid name:name msg:req.msg];
    result.accept = accept;
    result.status = RosterItemDelRequestRequesting;
    if ([m_rosterAddResultTb insertResult:result]) {
        [m_session post:result];
    } else {
        return NO;
    }
    return YES;
}

- (BOOL)delItemWithUid:(NSString *)uid {
    RosterItemDelRequest *req = [[RosterItemDelRequest alloc] initWithFrom:m_sid to:uid];
    req.status = RosterItemDelRequestRequesting;
    BOOL ret = [m_rosterDelTb insertReq:req];
    if (ret) {
        [m_session post:req];
    }
    return ret;
}

- (void)getRosterWithKey:(NSString *)key
                iv:(NSString *)iv
               url:(NSString *)url
             token:(NSString *)token {
    
    JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_ROSTER_ALL token:token key:key iv:iv];
    [param.params setObject:@"nothing" forKey:@"content"];
    JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    [session request:req success:^(JRReqest *request, JRResponse *resp) {
        JRTextResponse *txtResp = (JRTextResponse *)resp;
        m_roster = [[Roster alloc] initWithResult:txtResp.text ext:txtResp.ext];
        

    } failure:^(JRReqest *request, NSError *error) {
        DDLogError(@"get roster errror %@", error);
    } cancel:^(JRReqest *request) {
        
    }];
}

- (void)setRosterGrpWithKey:(NSString *)key
                         iv:(NSString *)iv
                        url:(NSString *)url
                      token:(NSString *)token {
    JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_SET_ROSTER_GRP token:token key:key iv:iv];
    NSString *grp = @"{\"1\":\"我的好友\",\"2\":\"我的同事\"}";
    [param.params setObject:grp forKey:@"grp"];
    JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    [session request:req success:^(JRReqest *request, JRResponse *resp) {
        DDLogInfo(@"INFO: set grp sucess.");
        
    } failure:^(JRReqest *request, NSError *error) {
        DDLogError(@"ERROR: set grp errror");
    } cancel:^(JRReqest *request) {
        
    }];
}


- (void)setRosterSignatureWithKey:(NSString *)key
                               iv:(NSString *)iv
                              url:(NSString *)url
                            token:(NSString *)token {
    JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_SET_ROSTER_SIGN token:token key:key iv:iv];
    NSString *sign = @"今天挺冷的！";
    [param.params setObject:sign forKey:@"sign"];
    JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    [session request:req success:^(JRReqest *request, JRResponse *resp) {
        DDLogInfo(@"INFO: set sign sucess.");
        
    } failure:^(JRReqest *request, NSError *error) {
        DDLogError(@"ERROR: set sign errror");
    } cancel:^(JRReqest *request) {
        
    }];
}


- (void)setRosterAvatarWithKey:(NSString *)key
                            iv:(NSString *)iv
                           url:(NSString *)url
                         token:(NSString *)token {
    JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_SET_ROSTER_AVATAR token:token key:key iv:iv];
    NSString *avatar = @"这是一个人的头像";
    [param.params setObject:avatar forKey:@"avatar"];
    JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    [session request:req success:^(JRReqest *request, JRResponse *resp) {
        DDLogInfo(@"INFO: set avatar sucess.");
        
    } failure:^(JRReqest *request, NSError *error) {
        DDLogError(@"ERROR: set avatar errror");
    } cancel:^(JRReqest *request) {
        
    }];
}

- (void)setRosterItemNameWithKey:(NSString *)key
                              iv:(NSString *)iv
                             url:(NSString *)url
                           token:(NSString *)token {
    JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_SET_ROSTER_ITEM_NAME token:token key:key iv:iv];
    [param.params setObject:@"gzw" forKey:@"fid"];
    [param.params setObject:@"郭志伟" forKey:@"name"];
    JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    [session request:req success:^(JRReqest *request, JRResponse *resp) {
        DDLogInfo(@"INFO: set ItemName sucess.");
        
    } failure:^(JRReqest *request, NSError *error) {
        DDLogError(@"ERROR: set ItemName errror");
    } cancel:^(JRReqest *request) {
        
    }];
}

- (void)setRosterItemGidWithKey:(NSString *)key
                             iv:(NSString *)iv
                            url:(NSString *)url
                          token:(NSString *)token {
    JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_SET_ROSTER_ITEM_GID token:token key:key iv:iv];
    [param.params setObject:@"gzw" forKey:@"fid"];
    [param.params setObject:@"2" forKey:@"gid"];
    JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    [session request:req success:^(JRReqest *request, JRResponse *resp) {
        DDLogInfo(@"INFO: set ItemGid sucess.");
        
    } failure:^(JRReqest *request, NSError *error) {
        DDLogError(@"ERROR: set ItemGid errror");
    } cancel:^(JRReqest *request) {
        
    }];
}


- (NSString *)version {
    return m_ver;
}

- (void)reset {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kIMAckNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRosterItemAddRequest object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRosterItemAddNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRosterItemDelNotification object:nil];
}


- (BOOL)parseRoster:(Roster *)roster {
    
    roster.uid = @"uuid";
    

    roster.items = @"[{\"uid\":\"xyy\", \"name\":\"许洋洋\", \"desc\":\"我来自江苏！\"}, {\"uid\":\"gzw\", \"name\":\"郭志伟\", \"desc\":\"我来自山西！\"}, {\"uid\":\"wjw\", \"name\":\"王家万\", \"desc\":\"我来自安徽！\"}]";
    roster.grp = @"[{\"gid\":\"grp1\", \"name\":\"我的好友\"}, {\"gid\":\"grp2\", \"name\":\"陌生人\"}]";
    roster.desc = @"{\"gzw\":\"grp1\", \"wjw\":\"grp2\", \"xyy\":\"grp2\"}";
    roster.ver = @"0.1";
    
    
    m_ver = roster.ver;
    
    NSArray *items = [Utils jsonCollectionFromString:roster.items];

    NSArray *grp = [Utils jsonCollectionFromString:roster.grp];
    NSDictionary *desc = [Utils jsonCollectionFromString:roster.desc];
    
    if (items == nil || grp == nil || desc == nil) {
        DDLogCError(@"ERROR: parse roster.");
        return NO;
    }
    
    if (![self buildRgcWithItems:items grp:grp desc:desc]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)buildRgcWithItems:(NSArray *)items grp:(NSArray *)grps desc:(NSDictionary *)desc {
    _rosterGroupContainer = [[RosterGroupContainer alloc] initWithItems:items grps:grps desc:desc];
    
    if (!_rosterGroupContainer) {
        return NO;
    }
    return YES;
}


#pragma mark - handle notification

- (void)handleIMAck:(NSNotification *)notification {
    IMAck *ack = notification.object;
    if (ack.ackType == IM_ROSTER_ITEM_ADD_REQUEST) {
       BOOL ret = [m_rosterAddTb updateReqStatusWithMsgid:ack.msgid status: ack.error ? RosterItemAddReqStatusError: RosterItemAddReqStatusACK];
        if (!ret) {
            DDLogWarn(@"ERROR: update RosterItemAddReqTb.");
        }
    }
    
    if (ack.ackType == IM_ROSTER_ITEM_DEL_REQUEST) {
        BOOL ret = [m_rosterDelTb updateReqStatus:(ack.error ? RosterItemDelRequestStatusError : RosterItemDelRequestStatusACK) MsgId:ack.msgid];
        if (!ret) {
            DDLogWarn(@"ERROR: update RosterItemDelReqTb.");
        }
    }
    
    if (ack.ackType == IM_ROSTER_ITEM_ADD_RESULT) {
        BOOL ret = [m_rosterAddResultTb updateResultStatus:ack.error ? RosterItemAddResultError : RosterItemAddResultAck MsgId:ack.msgid];
        if (!ret) {
            DDLogWarn(@"ERROR: update RosterItemAddResultTb.");
        }
    }
}

- (void)handleRosterItemAddReq:(NSNotification *)notification {
    RosterItemAddRequest *req = (RosterItemAddRequest *)notification.object;
    req.status = RosterItemAddReqStatusRequesting;
    BOOL ret = [m_rosterAddTb insertReq:req];
    IMAck *ack = [[IMAck alloc] initWithMsgid:req.qid ackType:req.type err:(ret ? nil :@"ERROR: insert roster req.")];
    [m_session post:ack];
}

- (void)handleRosterItemAddNotify:(NSNotification *)notification {
    
}

- (void)handleRosterItemDelNotify:(NSNotification *)notification {
    
}

@end
