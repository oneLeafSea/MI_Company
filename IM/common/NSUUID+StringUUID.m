//
//  NSUUID+StringUUID.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "NSUUID+StringUUID.h"

@implementation NSUUID (StringUUID)

+ (NSString *)uuid {
    NSUUID *uuid = [NSUUID UUID];
    NSString *ret = [uuid UUIDString];
    return ret;
}

@end
