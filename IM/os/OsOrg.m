//
//  OsOrg.m
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "OsOrg.h"

@implementation OsOrg

- (instancetype) initWithJgbm:(NSString *)jgbm
                         jgmc:(NSString *)jgmc
                         jgjc:(NSString *)jgjc
                       sjjgbm:(NSString *)sjjgbm
                           xh:(NSString *)xh {
    if (self = [super init]) {
        self.jgbm = [jgbm copy];
        self.jgmc = [jgmc copy];
        self.jgjc = [jgjc copy];
        self.sjjgbm = [sjjgbm copy];
        self.xh = [xh copy];
    }
    return self;
}

@end
