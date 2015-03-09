//
//  PresenceMgr.m
//  IM
//
//  Created by 郭志伟 on 15-2-19.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "PresenceMgr.h"
#import "AppDelegate.h"
#import "PresenceMsg.h"

@implementation PresenceMgr

- (void) postMsgWithPresenceType:(NSString *)presencetype
                    presenceShow:(NSString *)presenceShow {
    PresenceMsg *msg = [[PresenceMsg alloc] initWithPresenceType:presencetype show:presenceShow];
    [USER.session post:msg];
}


@end
