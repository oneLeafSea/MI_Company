//
//  bsonPkg.m
//  WH
//
//  Created by 郭志伟 on 14-10-14.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Pkg.h"

@implementation Pkg

- (instancetype)init {
    if (self = [super init]) {
        _data = nil;
        _dataType = UINT32_MAX;
        _dataType = UINT32_MAX;
    }
    return self;
}

- (instancetype) initWithType:(UInt32) dataType data:(NSData *)data {
    if (self = [self init]) {
        _data = data;
        _dataType = dataType;
    }
    return self;
}


@end