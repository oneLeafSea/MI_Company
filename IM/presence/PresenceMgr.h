//
//  PresenceMgr.h
//  IM
//
//  Created by 郭志伟 on 15-2-19.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresenceMsg.h"

@interface PresenceMgr : NSObject

- (void)postMsgWithPresenceType:(NSString *)presencetype presenceShow:(NSString *)presenceShow;


- (NSArray *)getPresenceMsgArrayByUid:(NSString *)uid;

- (BOOL) isOnline:(NSString *)uid;
@end
