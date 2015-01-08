//
//  RosterItemAddReqTb.h
//  IM
//
//  Created by 郭志伟 on 15-1-5.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "RosterItemAddRequest.h"

@interface RosterItemAddReqTb : NSObject

- (instancetype)initWithdbQueue:(FMDatabaseQueue *)dbq;

- (BOOL) insertReq:(RosterItemAddRequest *)req;
- (BOOL) updateReq:(RosterItemAddRequest *)req;
- (BOOL) delReq:(RosterItemAddRequest *)req;
- (BOOL) updateReqStatusWithMsgid:(NSString *)msgid status:(RosterItemAddReqStatus) status;
- (RosterItemAddRequest *) getReqWithMsgId:(NSString *)msgid;

@end
