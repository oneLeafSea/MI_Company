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
#import "JRTableResponse.h"
#import "NSUUID+StringUUID.h"
#import "RosterGroup.h"

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

- (BOOL)acceptRosterItemWithMsgid:(NSString *)msgid
                          groupId:(NSString *)gid
                             name:(NSString *)name
                           accept:(BOOL)accept {
#warning "这个函数没有测试！"
    RosterItemAddRequest *req = [m_rosterAddTb getReqWithMsgId:msgid];
    RosterItemAddResult *result = [[RosterItemAddResult alloc] initWithFrom:m_sid to:req.from gid:gid name:name msg:req.msg];
    result.qid = req.qid;
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
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_ROSTER_ALL token:token key:key iv:iv];
    [param.params setObject:@"nothing" forKey:@"content"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            __block JRTextResponse *txtResp = (JRTextResponse *)resp;
            dispatch_async(dispatch_get_main_queue(), ^{
                m_roster = [[Roster alloc] initWithResult:txtResp.text ext:txtResp.ext];
            });
        } failure:^(JRReqest *request, NSError *error) {
            DDLogError(@"get roster errror %@", error);
        } cancel:^(JRReqest *request) {
            
        }];
    });
    
}

- (void)setRosterGrpWithKey:(NSString *)key
                         iv:(NSString *)iv
                        url:(NSString *)url
                      token:(NSString *)token
                        grp:(NSDictionary *)grp
                 completion:(void (^)(BOOL finished))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_SET_ROSTER_GRP token:token key:key iv:iv];
    NSString *strGrp = [[NSString alloc] initWithData:[Utils jsonDataFromDict:grp] encoding:NSUTF8StringEncoding];
    
    [param.params setObject:strGrp forKey:@"grp"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"INFO: set grp sucess.");
                completion(YES);
            });
        } failure:^(JRReqest *request, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogError(@"ERROR: set grp errror");
                completion(NO);
            });
            
        } cancel:^(JRReqest *request) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogError(@"ERROR: set grp cancel");
                completion(NO);
            });
        }];
    });
}


- (void)setRosterItemSignatureWithKey:(NSString *)key
                               iv:(NSString *)iv
                              url:(NSString *)url
                            token:(NSString *)token {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_SET_ROSTER_SIGN token:token key:key iv:iv];
    NSString *sign = @"今天挺冷的！";
    [param.params setObject:sign forKey:@"sign"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            DDLogInfo(@"INFO: set sign sucess.");
            
        } failure:^(JRReqest *request, NSError *error) {
            DDLogError(@"ERROR: set sign errror");
        } cancel:^(JRReqest *request) {
            
        }];
    });
    
    
}


- (void)setRosterItemAvatarWithKey:(NSString *)key
                            iv:(NSString *)iv
                           url:(NSString *)url
                         token:(NSString *)token {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_SET_ROSTER_AVATAR token:token key:key iv:iv];
    NSString *avatar = @"这是一个人的头像";
    [param.params setObject:avatar forKey:@"avatar"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            DDLogInfo(@"INFO: set avatar sucess.");
            
        } failure:^(JRReqest *request, NSError *error) {
            DDLogError(@"ERROR: set avatar errror");
        } cancel:^(JRReqest *request) {
            
        }];
    });
    
}

- (void)setRosterItemNameWithKey:(NSString *)key
                              iv:(NSString *)iv
                             url:(NSString *)url
                           token:(NSString *)token {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_SET_ROSTER_ITEM_NAME token:token key:key iv:iv];
    [param.params setObject:@"gzw" forKey:@"fid"];
    [param.params setObject:@"郭志伟" forKey:@"name"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            DDLogInfo(@"INFO: set ItemName sucess.");
            
        } failure:^(JRReqest *request, NSError *error) {
            DDLogError(@"ERROR: set ItemName errror");
        } cancel:^(JRReqest *request) {
            
        }];
    });
}

- (void)setRosterItemGidWithKey:(NSString *)key
                             iv:(NSString *)iv
                            url:(NSString *)url
                          token:(NSString *)token {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_SET_ROSTER_ITEM_GID token:token key:key iv:iv];
    [param.params setObject:@"gzw" forKey:@"fid"];
    [param.params setObject:@"2" forKey:@"gid"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            DDLogInfo(@"INFO: set ItemGid sucess.");
            
        } failure:^(JRReqest *request, NSError *error) {
            DDLogError(@"ERROR: set ItemGid errror");
        } cancel:^(JRReqest *request) {
            
        }];
    });
    
}

- (void)searchRosterItemsWithContent:(NSString *)content
                            curPage:(NSUInteger)curPage
                             pageSz:(NSUInteger)pageSz
                                org:(NSString *)org
                                key:(NSString *)key
                                 iv:(NSString *)iv
                                url:(NSString *)url
                              token:(NSString *)token
                         completion:(void (^)(BOOL finished, NSArray *data, NSUInteger curPage))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:SVC_IM];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_USER_LIST token:token key:key iv:iv];
    
    [param.params setObject:[NSString stringWithFormat:@"%lu", (unsigned long)curPage] forKey:@"cur"];
    [param.params setObject:[NSString stringWithFormat:@"%lu", (unsigned long)pageSz] forKey:@"pagesize"];
    if (content.length != 0) {
        [param.params setObject:content forKey:@"name"];
    }
    if (org.length != 0) {
        [param.params setValue:org forKey:@"org"];
    }
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            __block JRTableResponse *tbResp = (JRTableResponse *)resp;
            __block NSArray *ret = [self parseSearchResult:tbResp.result];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *cur = [tbResp.ext objectForKey:@"cur"];
                completion(YES, ret, [cur integerValue]);
            });
            
        } failure:^(JRReqest *request, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil, 0);
            });
        } cancel:^(JRReqest *request) {
            completion(NO, nil, 0);
        }];
    });
}


- (NSArray *)parseSearchResult:(NSArray *) result {
    NSMutableArray *ret = ret = [[NSMutableArray alloc] initWithCapacity:20];
    for (NSArray *item in result) {
        NSMutableDictionary *i = [[NSMutableDictionary alloc] initWithCapacity:3];
        for (NSDictionary *dict in item) {
            
            NSString *n = [dict objectForKey:@"n"];
            NSString *v = [dict objectForKey:@"v"];
            [i setObject:v forKey:n];
        }
        [ret addObject:i];
    }
    return ret;
}

- (NSArray *)grouplist {
    __block NSMutableArray *grpList = [[NSMutableArray alloc] init];
    
    NSDictionary *grpdict = m_roster.rosterGroup;
    [grpdict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        RosterGroup *rg = [[RosterGroup alloc] init];
        rg.gid = key;
        rg.name = obj;
        [grpList addObject:rg];
    }];
    NSArray *rosterItems = [m_roster rosterItems];
    for (NSDictionary *item in rosterItems) {
        RosterItem *ri = [[RosterItem alloc] initWithDict:item];
        RosterGroup *g = [self getRosterGroupWithId:ri.gid grouplist:grpList];
        [g.items addObject:ri];
    }
    return grpList;
    
}

- (BOOL)addGroupWithName:(NSString *)grpName
                     key:(NSString *)key
                      iv:(NSString *)iv
                     url:(NSString *)url
                   token:(NSString *)token
              completion:(void (^)(BOOL finished))completion{
    if ([self exsitsGrpName:grpName]) {
        return NO;
    }
    NSMutableDictionary *grp = [[NSMutableDictionary alloc] initWithDictionary:m_roster.rosterGroup copyItems:YES];
    __block NSString *gid = [m_roster genGid];
    [grp setObject:grpName forKey:gid];
    
    __block Roster *roster = m_roster;
    [self setRosterGrpWithKey:key iv:iv url:url token:token grp:grp completion:^(BOOL finished) {
        [roster addGroupItemWithName:grpName gid:gid];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRosterGrpChanged object:nil];
        completion(finished);
    }];
    return YES;
}

- (BOOL)exsitsGrpName:(NSString *)grpName {
    NSArray *grpList = [self grouplist];
    for (RosterGroup *grp in grpList) {
        if ([grp.name isEqualToString:grpName]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)exsitsItemByUid:(NSString *)uid {
    NSArray *grpList = [self grouplist];
    for (RosterGroup *grp in grpList) {
        for (RosterItem *item in grp.items) {
            if ([item.uid isEqualToString:uid]) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSInteger)indexOfGrpWithName:(NSString *)name {
    __block NSInteger ret_idx = 0;
    NSArray *grp_list = [self grouplist];
    [grp_list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RosterGroup *grp = obj;
        if ([grp.name isEqualToString:name]) {
            ret_idx = idx;
            *stop = YES;
        }
    }];
    return ret_idx;
}

- (RosterGroup *)getRosterGroupWithId:(NSString *)gid grouplist:(NSArray *)grplist {
    RosterGroup * g = nil;
    for (RosterGroup *rg in grplist) {
        if ([rg.gid isEqualToString:gid]) {
            g = rg;
        }
    }
    return g;
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
    [self acceptRosterItemWithMsgid:req.qid groupId:@"1" name:@"郭志伟" accept:YES];
}

- (void)handleRosterItemAddNotify:(NSNotification *)notification {
    
}

- (void)handleRosterItemDelNotify:(NSNotification *)notification {
    
}

@end
