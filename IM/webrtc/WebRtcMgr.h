//
//  WebRtcMgr.h
//  IM
//
//  Created by 郭志伟 on 15-3-26.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "session.h"

@interface WebRtcMgr : NSObject

- (instancetype) initWithUid:(NSString *)uid;

- (void)setbusy:(BOOL)busy;

- (void)sendSignalWithType:(NSString *)type isSelf:(BOOL)isSelf roomId:(NSString *)roomId;

- (void)sendCloseSignalWithTalkingId:(NSString *)talkingId roomId:(NSString *)rid;


@property(nonatomic, readonly) NSString *uid;

- (void)inviteUid:(NSString *)uid session:(Session *)session;
@end
