//
//  IMConf.m
//  IM
//
//  Created by 郭志伟 on 14-12-26.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "IMConf.h"

@implementation IMConf

- (instancetype)init {
    self = [super init];
    if (self) {
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}


- (BOOL) setup {
    if (![self LoadIpAndPort]) {
        return NO;
    }
    return YES;
}


- (BOOL)LoadIpAndPort {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _IP = [ud objectForKey:@"IP"];
    NSNumber *port = [ud objectForKey:@"port"];
    _port = port.unsignedIntValue;
    
    return YES;
}


+(void) setIPAndPort:(NSString *)IP port:(UInt32)port {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:IP forKey:@"IP"];
    [ud setObject:[NSNumber numberWithUnsignedInt:port] forKey:@"port"];
}

@end
