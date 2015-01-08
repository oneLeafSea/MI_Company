//
//  RosterItemDelReqTb.h
//  IM
//
//  Created by 郭志伟 on 15-1-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "RosterItemDelRequest.h"

@interface RosterItemDelReqTb : NSObject

- (instancetype)initWithDbQueue:(FMDatabaseQueue *) dbQueue;

- (BOOL) insertReq:(RosterItemDelRequest *)req;
- (BOOL) updateReq:(RosterItemDelRequest *)req;
- (BOOL) updateReqStatus:(RosterItemDelRequestStatus)status MsgId:(NSString *)msgid;
- (BOOL) delReqWithMsgId:(NSString *)msgid;
- (NSArray *)get;

@end
