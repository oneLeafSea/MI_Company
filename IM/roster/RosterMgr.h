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

/**
 * set roster group.
 **/
- (void)setRosterGrpWithKey:(NSString *)key
                         iv:(NSString *)iv
                        url:(NSString *)url
                      token:(NSString *)token
                        grp:(NSDictionary *)grp;

/**
 * set roster Signature.
 **/
- (void)setRosterItemSignatureWithKey:(NSString *)key
                         iv:(NSString *)iv
                        url:(NSString *)url
                      token:(NSString *)token;

/**
 * set roster item Avatar.
 **/
- (void)setRosterItemAvatarWithKey:(NSString *)key
                            iv:(NSString *)iv
                           url:(NSString *)url
                         token:(NSString *)token;

/**
 * set roster item name.
 **/
- (void)setRosterItemNameWithKey:(NSString *)key
                              iv:(NSString *)iv
                             url:(NSString *)url
                           token:(NSString *)token;

/**
 * set roster item gid.
 **/
- (void)setRosterItemGidWithKey:(NSString *)key
                              iv:(NSString *)iv
                             url:(NSString *)url
                          token:(NSString *)token;


- (void)searchRosterItemsWithContent:(NSString *)content
                            curPage:(NSUInteger)curPage
                             pageSz:(NSUInteger)pageSz
                                org:(NSString *)org
                                key:(NSString *)key
                                 iv:(NSString *)iv
                                url:(NSString *)url
                              token:(NSString *)token
                         completion:(void (^)(BOOL finished, NSArray *data, NSUInteger curPage))completion;
/**
 * get group list.
 **/
- (NSArray *)grouplist;


- (BOOL)addGroupWithName:(NSString *)grpName
                     key:(NSString *)key
                      iv:(NSString *)iv
                     url:(NSString *)url
                   token:(NSString *)token
     completion:(void (^)(BOOL finished))completion;



- (BOOL)exsitsGrpName:(NSString *)grpName;

- (NSInteger)indexOfGrpWithName:(NSString *)name;

- (BOOL)exsitsItemByUid:(NSString *)uid;

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
//- (BOOL)parseRoster:(Roster *)roster;

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
