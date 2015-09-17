//
//  IMConf.m
//  IM
//
//  Created by 郭志伟 on 14-12-26.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "IMConf.h"

#import <arpa/inet.h>

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

+ (void)checkLAN:(Reachability *)reach {
    if (reach.currentReachabilityStatus !=  ReachableViaWiFi) {
        [IMConf setIPAndPort:@"221.224.159.26" port:48009];
        return;
    }
    if ([IMConf isLAN]) {
        [IMConf setIPAndPort:@"10.22.1.47" port:8000];
    } else {
        [IMConf setIPAndPort:@"221.224.159.26" port:48009];
    }
}

+(void) setLAN:(BOOL) Lan {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSNumber numberWithBool:Lan] forKey:@"LAN"];
}

+(BOOL) isLAN {
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    NSNumber *lan = [ud objectForKey:@"LAN"];
//    if (lan) {
//        return [lan boolValue];
//    }
//    return NO;
    struct sockaddr_in addr = {0};
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(48009);
    addr.sin_addr.s_addr = inet_addr("221.224.159.26");
    int s = socket(AF_INET, SOCK_STREAM, 0);
    
    int ret = connect(s, (struct sockaddr *)&addr, sizeof(struct sockaddr));
    close(s);
    if (ret == -1) {
        return YES;
    }
    
    return NO;
}



@end
