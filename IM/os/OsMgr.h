//
//  OsMgr.h
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "OsOrg.h"
#import "OsItem.h"

@interface OsMgr : NSObject


- (instancetype) initWithDbq:(FMDatabaseQueue *)queue;

- (void)getOrgVerWithToken:(NSString *)token
                 signature:(NSString *)signature
                       key:(NSString *)key
                        iv:(NSString *)iv
                       url:(NSString *)url
                completion:(void(^)(BOOL finished, NSString* version))completion;

- (void)getOrgWithToken:(NSString *)token
              signature:(NSString *)signature
                    key:(NSString *)key
                     iv:(NSString *)iv
                    url:(NSString *)url
             completion:(void(^)(BOOL finished))completion;

- (void)getOrgItemsVerWithToken:(NSString *)token
                      signature:(NSString *)signature
                            key:(NSString *)key
                             iv:(NSString *)iv
                            url:(NSString *)url
                     completion:(void(^)(BOOL finished, NSString *txt))completion;

- (void)getOrgItemsWithToken:(NSString *)token
                   signature:(NSString *)signature
                         key:(NSString *)key
                          iv:(NSString *)iv
                         url:(NSString *)url
                         ver:(NSString *)ver
                  completion:(void(^)(BOOL finished))completion;

- (void)syncOrgStructWithWithToken:(NSString *)token
                         signature:(NSString *)signature
                               key:(NSString *)key
                                iv:(NSString *)iv
                               url:(NSString *)url
                        completion:(void(^)(BOOL finished))completion;

- (NSArray *)getSubOrgs:(NSString *)jgbm;
- (NSArray *)getOrgItemsByJgbm:(NSString *)jgbm;
- (OsItem *)getItemInfoByUid:(NSString *)uid;
- (NSString *)getOrgNameByOrgId:(NSString *)orgId;

@property(atomic) NSString *orgVer;
@property(atomic) NSArray  *org;
@property(atomic) NSString *itemsVer;
@property(atomic) NSArray  *items;

@property(readonly) OsOrg *rootOrg;


@end
