//
//  OsMgr.m
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "OsMgr.h"
#import "JRSession.h"
#import "JRTableResponse.h"
#import "JRTextResponse.h"
#import "OsQid.h"
#import "OsOrgTb.h"
#import "OsOrgVerTb.h"
#import "OsItemsTb.h"
#import "OsItemsVerTb.h"
#import "LogLevel.h"

@interface OsMgr() {
    __weak FMDatabaseQueue *m_dbq;
    OsItemsTb              *m_itemsTb;
    OsItemsVerTb           *m_itemVerTb;
    OsOrgTb                *m_OrgTb;
    OsOrgVerTb             *m_OrgVerTb;
}
@end

@implementation OsMgr

- (instancetype) initWithDbq:(FMDatabaseQueue *)queue {
    if (self = [super init]) {
        m_dbq = queue;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup {
    if (![self createTb]) {
        return NO;
    }
    return YES;
}

- (BOOL)createTb {
    m_OrgTb = [[OsOrgTb alloc] initWithDbq:m_dbq];
    if (!m_OrgTb) {
        return NO;
    }
    
    m_OrgVerTb = [[OsOrgVerTb alloc] initWithDbq:m_dbq];
    if (!m_OrgVerTb) {
        return NO;
    }
    
    m_itemsTb = [[OsItemsTb alloc] initWithDbq:m_dbq];
    if (!m_itemsTb) {
        return NO;
    }
    
    m_itemVerTb = [[OsItemsVerTb alloc] initWithDbq:m_dbq];
    if (!m_itemVerTb) {
        return NO;
    }
    
    return YES;
}

- (void)getOrgVerWithToken:(NSString *)token
                 signature:(NSString *)signature
                       key:(NSString *)key
                        iv:(NSString *)iv
                       url:(NSString *)url
                completion:(void(^)(BOOL finished, NSString* version))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_DEPT_VER token:token key:key iv:iv];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTextResponse class]]) {
                JRTextResponse *txtResp = (JRTextResponse *)resp;
                NSString *ver = [txtResp.text copy];
                completion(YES, ver);
            } else {
                completion(NO, nil);
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(NO, nil);
            
        } cancel:^(JRReqest *request) {
            completion(NO, nil);
        }];
    });
}

- (void)getOrgWithToken:(NSString *)token
              signature:(NSString *)signature
                    key:(NSString *)key
                     iv:(NSString *)iv
                    url:(NSString *)url
             completion:(void(^)(BOOL finished))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_DEPT_LIST token:token key:key iv:iv];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTableResponse class]]) {
                JRTableResponse *tbResp = (JRTableResponse *)resp;
                if ([self parseOrgRespose:tbResp]) {
                    if ([m_OrgTb delAll]) {
                        if (![m_OrgTb insertOrgArray:self.org]) {
                            DDLogError(@"ERROR:insert tb_os_org table.");
                            completion(NO);
                        } else {
                            completion(YES);
                        }
                    } else {
                        DDLogError(@"ERROR:delete tb_os_org table.");
                        completion(NO);
                    }
                } else {
                    DDLogError(@"ERROR:parse os org.");
                    completion(NO);
                }
            } else {
                DDLogError(@"ERROR: get org from server.");
                completion(NO);
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(NO);
            
        } cancel:^(JRReqest *request) {
            completion(NO);
        }];
    });
}

- (BOOL)parseOrgRespose:(JRTableResponse *)response {
    __block BOOL ret = YES;
    NSArray *result = response.result;
    __block NSMutableArray *orgs = [[NSMutableArray alloc] init];
    [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *item = obj;
        __block NSString *jgbm = nil;
        __block NSString *jgmc = nil;
        __block NSString *jgjc = nil;
        __block NSString *sjjgbm = nil;
        __block NSString *xh = nil;
        [item enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *n = [obj objectForKey:@"n"];
            NSString *v = [obj objectForKey:@"v"];
            if ([n isEqualToString:@"jgbm"]) {
                jgbm = [v copy];
            }
            if ([n isEqualToString:@"jgmc"]) {
                jgmc = [v copy];
            }
            if ([n isEqualToString:@"jgjc"]) {
                jgjc = [v copy];
            }
            if ([n isEqualToString:@"sjjgbm"]) {
                sjjgbm = [v copy];
            }
            if ([n isEqualToString:@"xh"]) {
                xh = [v copy];
            }
        }];
        OsOrg *org = [[OsOrg alloc] initWithJgbm:jgbm jgmc:jgmc jgjc:jgjc sjjgbm:sjjgbm xh:xh];
        if (!org) {
            ret = NO;
            *stop = YES;
        }
        [orgs addObject:org];
    }];
    if (ret) {
        self.org = orgs;
    }
    return ret;
}

- (void)getOrgItemsVerWithToken:(NSString *)token
                      signature:(NSString *)signature
                            key:(NSString *)key
                             iv:(NSString *)iv
                            url:(NSString *)url
                     completion:(void(^)(BOOL finished, NSString* version))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_CONTACTS_VER token:token key:key iv:iv];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTextResponse class]]) {
                JRTextResponse *txtResp = (JRTextResponse *)resp;
                completion(YES, txtResp.text);
            } else {
                completion(NO, nil);
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(NO, nil);
            
        } cancel:^(JRReqest *request) {
            completion(NO, nil);
        }];
    });
}

- (void)getOrgItemsWithToken:(NSString *)token
                   signature:(NSString *)signature
                         key:(NSString *)key
                          iv:(NSString *)iv
                         url:(NSString *)url
                         ver:(NSString *)ver
                  completion:(void(^)(BOOL finished))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_CONTACTS_LIST token:token key:key iv:iv];
    NSString *itemVer = ver ? ver : @"0";
    [param.params setObject:itemVer forKey:@"ver"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTableResponse class]]) {
                JRTableResponse *tbResp = (JRTableResponse *)resp;
                NSArray *needUpdateItems = [self parseItemsResp:tbResp];
                if (needUpdateItems) {
                    if ([self updateItemsDb:needUpdateItems]) {
                        completion(YES);
                    } else {
                        DDLogError(@"ERROR: os items save to db.");
                        completion(NO);
                    }
                } else {
                    DDLogError(@"ERROR: parse os items.");
                    completion(NO);
                }
            } else {
                completion(NO);
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(NO);
            
        } cancel:^(JRReqest *request) {
            completion(NO);
        }];
    });
}

- (BOOL)updateItemsDb:(NSArray *)needUpdateItems {
    __block BOOL ret = YES;
    [needUpdateItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        OsItem *item = obj;
        if ([item.op isEqualToString:@"i"]) {
            if (![m_itemsTb insertItem:item]) {
                DDLogError(@"ERROR: insert ostb error, try update.");
                if (![m_itemsTb updateItem:item]) {
                    ret = NO;
                    *stop = YES;
                }
            }
            return;
        }
        if ([item.op isEqualToString:@"u"]) {
            if (![m_itemsTb updateItem:item]) {
                ret = NO;
                *stop = YES;
            }
            return;
        }
        if ([item.op isEqualToString:@"d"]) {
            if (![m_itemsTb deleteItem:item]) {
                ret = NO;
                *stop = YES;
            }
            return;
        }
    }];
    return ret;
}

- (NSArray *)parseItemsResp:(JRTableResponse *)resp {
    __block BOOL ret = YES;
    NSArray *result = resp.result;
    DDLogInfo(@"INFO: os update info: %@", result);
    __block NSMutableArray *items = [[NSMutableArray alloc] init];
    [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *item = obj;
        __block NSString *uid = nil;
        __block NSString *name = nil;
        __block NSString *org = nil;
        __block NSString *op = nil;
        [item enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *n = [obj objectForKey:@"n"];
            NSString *v = [obj objectForKey:@"v"];
            if ([n isEqualToString:@"uname"]) {
                uid = v;
            }
            if ([n isEqualToString:@"name"]) {
                name = v;
            }
            if ([n isEqualToString:@"org"]) {
                org = v;
            }
            
            if ([n isEqualToString:@"op"]) {
                op = [v copy];
            }
        }];
        OsItem *osItem = [[OsItem alloc] initWithUid:uid name:name org:org];
        osItem.op = op;
        if (!item) {
            ret = NO;
            *stop = YES;
        }
        [items addObject:osItem];
    }];
    if (!ret) {
        items = nil;
    }
    return items;
}


- (void)syncOrgStructWithWithToken:(NSString *)token
                         signature:(NSString *)signature
                               key:(NSString *)key
                                iv:(NSString *)iv
                               url:(NSString *)url
                        completion:(void(^)(BOOL finished))completion {
    __block NSString *dbOrgVer = [m_OrgVerTb DbVer];
    [self getOrgVerWithToken:token signature:signature key:key iv:iv url:url completion:^(BOOL finished, NSString *orgVer) {
        if (![dbOrgVer isEqualToString:orgVer]) {
            [self getOrgWithToken:token signature:signature key:key iv:iv url:url completion:^(BOOL finished) {
                if (finished) {
                    self.orgVer = orgVer;
                    [m_OrgVerTb updateVer:orgVer];
                    __block NSString *dbItemsVer = [m_itemVerTb DbVer];
                    [self getOrgItemsVerWithToken:token signature:signature key:key iv:iv url:url completion:^(BOOL finished, NSString *itemsVer) {
                        if (finished) {
                            if (![dbItemsVer isEqualToString:itemsVer]) {
                                [self getOrgItemsWithToken:token signature:signature key:key iv:iv url:url ver:dbItemsVer completion:^(BOOL finished) {
                                    if (finished) {
                                        self.itemsVer = itemsVer;
                                        if (![m_itemVerTb updateVer:itemsVer]) {
                                            completion(NO);
                                        }
                                        self.items = [m_itemsTb getItems];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            completion(YES);
                                        });
                                    } else {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            completion(NO);
                                        });
                                    }
                                }];
                            } else {
                                self.items = [m_itemsTb getItems];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(YES);
                                });
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(NO);
                            });
                        }
                    }];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(NO);
                    });
                }
            }];
        } else {
            self.orgVer = dbOrgVer;
            self.org = [m_OrgTb getOrg];
            __block NSString *dbItemsVer = [m_itemVerTb DbVer];
            [self getOrgItemsVerWithToken:token signature:signature key:key iv:iv url:url completion:^(BOOL finished, NSString *itemsVer) {
                if (finished) {
                    if (![dbItemsVer isEqualToString:itemsVer]) {
                        [self getOrgItemsWithToken:token signature:signature key:key iv:iv url:url ver:dbItemsVer completion:^(BOOL finished) {
                            if (finished) {
                                self.itemsVer = itemsVer;
                                [m_itemVerTb updateVer:itemsVer];
                                self.items = [m_itemsTb getItems];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(YES);
                                });

                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(NO);
                                });
                            }
                        }];
                    } else {
                        self.itemsVer = dbItemsVer;
                        self.items = [m_itemsTb getItems];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(YES);
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(NO);
                    });
                }
            }];
        }
    }];
}

- (OsOrg *)rootOrg {
    return [m_OrgTb getRootOrg];
}

- (NSArray *)getSubOrgs:(NSString *)jgbm {
    return [m_OrgTb getSubOrgByJgbm:jgbm];
}

- (NSArray *)getOrgItemsByJgbm:(NSString *)jgbm {
    return [m_itemsTb getItemsByOrg:jgbm];
}

- (OsItem *)getItemInfoByUid:(NSString *)uid {
    return [m_itemsTb getItemByUid:uid];
}

@end
