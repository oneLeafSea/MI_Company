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

@protocol RosterMgrDelgate;

@interface RosterMgr : NSObject

/**
 * RosterMgr initialize
 * @param sid userId
 * @param sess The session which connected to sersver.
 * @return RosterMgr instance
 **/
- (instancetype)initWithSelfId:(NSString *)sid dbq:(FMDatabaseQueue *)dbq;

/**
 * add a roster item.
 * It will call delegate's method.
 * @param uid which is beiing added.
 **/
- (void)addItemWithTo:(NSString *)to
              groupId:(NSString *)gid
               reqmsg:(NSString *)reqmsg
              session:(Session *)session;


/**
 * Accept roster item.
 **/
- (void)acceptRosterItemId:(NSString *)uid
                    grouId:(NSString *)gid
                    accept:(BOOL) accept
                    session:(Session *)session;

/**
 * delete a roster item.
 * It will call delegate's method.
 * @param uid which is beiing added.
 **/
- (void)delItemWithUid:(NSString *)uid session:(Session *)session;


/**
 * request for the server to return the roster.
 * It will call delegate's method.
 **/
- (void)getWithSession:(Session *)session;

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


@property(weak) id<RosterMgrDelgate> delegate;

@end

@protocol RosterMgrDelgate <NSObject>

- (void)rosterMgr:(RosterMgr *)rm item:(RosterItem *)ri addItem:(BOOL)suc err:(NSError *)err;

- (void)rosterMgr:(RosterMgr *)rm item:(RosterItem *)ri delItem:(BOOL)suc err:(NSError *)err;

- (void)rosterMgr:(RosterMgr *)rm roster:(Roster *)roster get:(BOOL)suc err:(NSError *)err;

@end
