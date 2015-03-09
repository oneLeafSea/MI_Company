//
//  OsItem.m
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "OsItem.h"

@implementation OsItem

- (instancetype)initWithUid:(NSString *)uid
                       name:(NSString *)name
                        org:(NSString *)org {
    if (self = [super init]) {
        self.uid = [uid copy];
        self.name = [name copy];
        self.org = [org copy];
    }
    return self;
}

@end
