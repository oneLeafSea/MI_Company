//
//  RecentMgr.h
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "session.h"
#import "ChatMessage.h"
#import "RecentMsgItem.h"
#import "RosterItemAddRequest.h"

@interface RecentMgr : NSObject

- (instancetype)initWithUid:(NSString *)uid
                        dbq:(FMDatabaseQueue *)dbq
                    session:(Session *)session;

- (NSArray *) loadDbData;

- (BOOL) updateRevcChatMsg:(ChatMessage *) msg;

- (BOOL) updateSendChatMsg:(ChatMessage *) msg;

- (BOOL) updateChatMsgBadge:(NSString *)badge fromOrTo:(NSString *)fromOrTo chatmsgType:(UInt32) chatMsgtype;

- (NSInteger) getMsgBadgeSum;

- (BOOL) delMsgItem:(RecentMsgItem *)item;

- (BOOL) updateRosterItemAddReqMsg:(RosterItemAddRequest *)req;
- (BOOL) updateRosterItemAddReqBadge:(NSString *)bage;

@end
