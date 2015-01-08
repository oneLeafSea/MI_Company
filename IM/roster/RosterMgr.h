//
//  RosterMgr.h
//  IM
//
//  Created by 郭志伟 on 14-12-17.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "session.h"
#import "RosterItemAddRequest.h"
#import "RosterItemAddResult.h"
#import "Roster.h"
#import "RosterItem.h"
#import "FMDB.h"
#import "RosterGroupContainer.h"

@protocol RosterMgrDelgate;

@interface RosterMgr : NSObject

/**
 * RosterMgr initialize
 * @param sid userId
 * @param sess The session which connected to sersver.
 * @return RosterMgr instance
 **/
- (instancetype)initWithSelfId:(NSString *)sid dbq:(FMDatabaseQueue *)dbq session:(Session *)session;

/**
 * add a roster item.
 * @param uid which is beiing added.
 **/
- (BOOL)addItemWithTo:(NSString *)to
              groupId:(NSString *)gid
               reqmsg:(NSString *)reqmsg
             selfName:(NSString *)selfName;


/**
 * Accept roster item.
 **/
//- (BOOL)acceptRosterItemId:(NSString *)uid
//                    grouId:(NSString *)gid
//                      name:(NSString *)name
//                       msg:(NSString *)msg
//                    accept:(BOOL)accept;
// 还没有测试
- (BOOL)acceptRosterItemWithMsgid:(NSString *)msgid
                          groupId:(NSString *)gid
                             name:(NSString *)name
                           accept:(BOOL)accept;

/**
 * delete a roster item.
 * It will call delegate's method.
 * @param uid which is beiing added.
 **/
- (BOOL)delItemWithUid:(NSString *)uid;


/**
 * request for the server to return the roster.
 * It will call delegate's method.
 **/
- (void)getRosterWithKey:(NSString *)key
                iv:(NSString *)iv
               url:(NSString *)url
             token:(NSString *)token;


- (void)setRosterGrpWithKey:(NSString *)key
                         iv:(NSString *)iv
                        url:(NSString *)url
                      token:(NSString *)token;

- (void)setRosterSignatureWithKey:(NSString *)key
                         iv:(NSString *)iv
                        url:(NSString *)url
                      token:(NSString *)token;

- (void)setRosterAvatarWithKey:(NSString *)key
                            iv:(NSString *)iv
                           url:(NSString *)url
                         token:(NSString *)token;

- (void)setRosterItemNameWithKey:(NSString *)key
                              iv:(NSString *)iv
                             url:(NSString *)url
                           token:(NSString *)token;

- (void)setRosterItemGidWithKey:(NSString *)key
                              iv:(NSString *)iv
                             url:(NSString *)url
                          token:(NSString *)token;
/**
 * return the roster version
 **/
- (NSString *)version;

/**
 * handle roster item add request.
 **/
//- (void)handleRosterItemAddRequest:(RosterItemAddRequest *)req;


/**
 * handle roster item add result
 **/
//- (void)handleRosterItemAddResult:(RosterItemAddResult *)result;

/**
 * parse roster.
 **/
- (BOOL)parseRoster:(Roster *)roster;

/**
 * reset roster.
 */

- (void)reset;

@property(weak) id<RosterMgrDelgate> delegate;
@property(readonly) RosterGroupContainer *rosterGroupContainer;

@end

@protocol RosterMgrDelgate <NSObject>

- (void)rosterMgr:(RosterMgr *)rm item:(RosterItem *)ri addItem:(BOOL)suc err:(NSError *)err;

- (void)rosterMgr:(RosterMgr *)rm item:(RosterItem *)ri delItem:(BOOL)suc err:(NSError *)err;

- (void)rosterMgr:(RosterMgr *)rm roster:(Roster *)roster get:(BOOL)suc err:(NSError *)err;

@end
