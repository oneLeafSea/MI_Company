//
//  RecentTb.h
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "RecentMsgItem.h"

@interface RecentTb : NSObject

- (instancetype) initWithDbq:(FMDatabaseQueue *)dbq;

- (NSMutableArray *) loadMsgs;

- (BOOL) insertItem:(RecentMsgItem *)item;

- (BOOL) exsitMsgFrom:(NSString *)from msgtype:(UInt32) type;

- (BOOL) exsitMsgFromOrTo:(NSString *)fromTo msgtype:(UInt32)type;

- (BOOL) updateItem:(RecentMsgItem *)item msgtype:(UInt32)type fromOrTo:(NSString *)fromOrTo;

- (BOOL) updateItem:(RecentMsgItem *) item msgtyp:(UInt32)type;

- (NSInteger) getChatMsgBadgeWithFromOrTo:(NSString *)fromOrTo chatMsgType:(NSString *)chatMsgType;

- (BOOL) updateChatMsgBadge:(NSString *)badge fromOrTo:(NSString *) fromOrTo chatmsgType:(UInt32) chatMsgtype;

- (NSInteger) getMsgBadgeSum;

- (BOOL) delMsgItem:(RecentMsgItem *)item;

- (BOOL) exsitmsgType:(UInt32) type;

- (BOOL) updateRosterItemAddReqBadge:(NSString *)badge msgtype:(NSUInteger) msgtype;
- (NSInteger) getFirstBadgeWithMsgType:(NSInteger) msgtype;

@end
