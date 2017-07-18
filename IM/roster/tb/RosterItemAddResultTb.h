//
//  RosterItemAddResultTb.h
//  IM
//
//  Created by 郭志伟 on 15-1-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "RosterItemAddResult.h"


@interface RosterItemAddResultTb : NSObject

- (instancetype)initWithDbQueue:(FMDatabaseQueue *) dbQueue;
- (BOOL) insertResult:(RosterItemAddResult *)req;
- (BOOL) updateResult:(RosterItemAddResult *)req;
- (BOOL) updateResultStatus:(RosterItemAddResultStatus)status MsgId:(NSString *)msgid;
- (BOOL) delResultWithMsgId:(NSString *)msgid;
- (NSArray *)get;

@end
