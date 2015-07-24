//
//  RecentMgr.m
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RecentMgr.h"
#import "RecentTb.h"
#import "Utils.h"
#import "RecentMsgItem.h"
#import "MessageConstants.h"
#import "NSDate+Common.h"

static NSString *kChatMessageTypeNomal = @"0";

@interface RecentMgr() {
    RecentTb *m_recentTb;
    __weak FMDatabaseQueue *m_dbq;
    __weak Session *m_sess;
}

@end

@implementation RecentMgr

- (instancetype)initWithUid:(NSString *)uid
                        dbq:(FMDatabaseQueue *)dbq
                    session:(Session *)session {
    if (self = [super init]) {
        m_dbq = dbq;
        m_sess = session;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup {
    m_recentTb = [[RecentTb alloc] initWithDbq:m_dbq];
    if (!m_recentTb) {
        return NO;
    }
    return YES;
}

- (NSArray *)loadDbData {
    return [m_recentTb loadMsgs];
}


- (BOOL) updateRevcChatMsg:(ChatMessage *) msg {
    RecentMsgItem *item = [self cnvtRecentMsgItemWithChatMsg:msg];
    BOOL ret = YES;
    
    if ([item.ext isEqualToString:kChatMessageTypeNomal]) {
        if ([m_recentTb exsitMsgFromOrTo:item.from msgtype:IM_MESSAGE ext:item.ext]) {
            NSInteger badge = [m_recentTb getChatMsgBadgeWithFromOrTo:item.from chatMsgType:item.ext];
            if (badge <= 0) {
                item.badge = @"1";
            } else  {
                badge++;
                item.badge = [NSString stringWithFormat:@"%ld", (long)badge];
            }
            
            ret = [m_recentTb updateItem:item msgtype:msg.type fromOrTo:item.from];
        } else {
            ret = [m_recentTb insertItem:item];
        }
    } else {
        if ([m_recentTb exsitMsgFromOrTo:item.to msgtype:IM_MESSAGE ext:item.ext]) {
            NSInteger badge = [m_recentTb getChatMsgBadgeWithFromOrTo:item.to chatMsgType:item.ext];
            if (badge <= 0) {
                item.badge = @"1";
            } else  {
                badge++;
                item.badge = [NSString stringWithFormat:@"%ld", (long)badge];
            }
            
            ret = [m_recentTb updateItem:item msgtype:msg.type fromOrTo:item.to];
        } else {
            ret = [m_recentTb insertItem:item];
        }
    }
    
    
    return ret;
}

- (BOOL) updateSendChatMsg:(ChatMessage *) msg {
    RecentMsgItem *item = [self cnvtRecentMsgItemWithChatMsg:msg];
    BOOL ret = YES;
    if ([item.ext isEqualToString:kChatMessageTypeNomal]) {
        if ([m_recentTb exsitMsgFromOrTo:item.to msgtype:IM_MESSAGE ext:item.ext]) {
            ret = [m_recentTb updateItem:item msgtype:msg.type fromOrTo:item.to];
        } else {
            ret = [m_recentTb insertItem:item];
        }
    } else {
        if ([m_recentTb exsitMsgFromOrTo:item.to msgtype:IM_MESSAGE ext:item.ext]) {
            ret = [m_recentTb updateItem:item msgtype:msg.type fromOrTo:item.to];
        } else {
            ret = [m_recentTb insertItem:item];
        }
    }
    
    
    return ret;
}

- (RecentMsgItem *)cnvtRecentMsgItemWithChatMsg:(ChatMessage *)msg {
    NSDictionary *contentDict = @{
                                  @"from":msg.from,
                                  @"to":msg.to,
                                  @"type":[NSNumber numberWithUnsignedInt:msg.type],
                                  @"time":msg.time,
                                  @"body":msg.body,
                                  @"msgid":msg.qid,
                                  @"chatmsgtype":[NSNumber numberWithUnsignedInt:msg.chatMsgType]
                                  };
    
    NSData *contentData = [Utils jsonDataFromDict:contentDict];
    NSString *content = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
    RecentMsgItem *item = [[RecentMsgItem alloc] init];
    item.msgid = msg.qid;
    item.msgtype = msg.type;
    item.time = msg.time;
    item.content = content;
    item.from = msg.from;
    item.to = msg.to;
    item.badge = @"0";
    item.ext = [NSString stringWithFormat:@"%u", (unsigned int)msg.chatMsgType];
    return item;
}

- (BOOL) updateChatMsgBadge:(NSString *)badge fromOrTo:(NSString *)fromOrTo chatmsgType:(UInt32) chatMsgtype {
    return [m_recentTb updateChatMsgBadge:badge fromOrTo:fromOrTo chatmsgType:chatMsgtype];
}

- (NSInteger) getMsgBadgeSum {
    return [m_recentTb getMsgBadgeSum];
}

- (BOOL) delMsgItem:(RecentMsgItem *)item {
    return [m_recentTb delMsgItem:item];
}

#pragma mark - roster item add req msg.

- (BOOL) updateRosterItemAddReqMsg:(RosterItemAddRequest *)req {
    RecentMsgItem *item = [self cnvtRecentMsgItemWithRosterItemAddReq:req];
    BOOL ret = YES;
    if ([m_recentTb exsitmsgType:req.type]) {
        NSInteger badge = [m_recentTb getFirstBadgeWithMsgType:req.type];
        item.badge = [NSString stringWithFormat:@"%ld", badge + 1];
        ret = [m_recentTb updateItem:item msgtyp:req.type];
    } else {
        ret = [m_recentTb insertItem:item];
    }
    
    return ret;
}

- (BOOL) updateRosterItemAddReqBadge:(NSString *)bage {
    return [m_recentTb updateRosterItemAddReqBadge:bage msgtype:IM_ROSTER_ITEM_ADD_REQUEST];
}

- (RecentMsgItem *)cnvtRecentMsgItemWithRosterItemAddReq:(RosterItemAddRequest *)req {
    NSParameterAssert(req.from);
    NSParameterAssert(req.to);
    NSParameterAssert(req.msg);
    NSParameterAssert(req.qid);
    NSString *time = req.time;
    if (!time) {
        time = [[NSDate Now] formatWith:nil];
    }
    NSDictionary *contentDict = @{
                                  @"from":req.from,
                                  @"to":req.to,
                                  @"msg":req.msg,
                                  @"time":time,
                                  @"msgid":req.qid,
                                  };
    NSData *contentData = [Utils jsonDataFromDict:contentDict];
    NSString *content = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
    RecentMsgItem *item = [[RecentMsgItem alloc] init];
    item.msgid = req.qid;
    item.msgtype = req.type;
    item.time = time;
    item.content = content;
    item.from = req.from;
    item.to = req.to;
    item.ext = @"";
    item.badge = @"0";
    return item;
}

- (void)reset {
    
}

@end
