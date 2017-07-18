//
//  DictVersions.m
//  WH
//
//  Created by 郭志伟 on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "DictsVersion.h"
#import "LogLevel.h"

@implementation DictsVersion

- (instancetype) initWithDvData:(NSDictionary *)dvd {
    if (self = [super init]) {
        _data = dvd;
    }
    return self;
}

- (NSArray *)allDictNames {
    return [self.data allKeys];
}

@end
