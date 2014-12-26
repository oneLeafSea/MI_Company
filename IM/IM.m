//
//  IM.m
//  IM
//
//  Created by 郭志伟 on 14-12-26.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "IM.h"
#import "LogLevel.h"

@interface IM() <SessionDelegate>

@property(nonatomic, strong) Session *session;

@end

@implementation IM

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup {
    self.cfg = [[IMConf alloc] init];
    if (!self.cfg) {
        DDLogError(@"ERROR: load IM cfg");
        return NO;
    }
    
    self.session = [[Session alloc] init];
    self.session.delegate = self;
    return YES;
}

- (void)login {
    
}


#pragma mark - session delegate

- (void)session:(Session *)sess connected:(BOOL)connected timeout:(BOOL)timeout error:(NSError *)error {
    
}

- (void)session:(Session *)sess serverTime:(NSString *)serverTime {
    
}

- (void)sessionDied:(Session *)sess error:(NSError *)err {
    
}


@end
