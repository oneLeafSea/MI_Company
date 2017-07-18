//
//  IMConf.h
//  IM
//
//  Created by 郭志伟 on 14-12-26.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Reachability.h"

@interface IMConf : NSObject

@property(readonly) NSString *IP;
@property(readonly) UInt32   port;

+ (void)setIPAndPort:(NSString *)IP port:(UInt32)port;


+ (BOOL)isLAN;


+ (void)checkLAN:(Reachability *)reach;

@end
