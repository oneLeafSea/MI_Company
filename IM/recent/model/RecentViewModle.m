//
//  RecentViewModle.m
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RecentViewModle.h"

@implementation RecentViewModle

- (instancetype)initWithDbData:(NSArray *)dbData {
    if (self = [super init]) {
        _msgList = dbData;
    }
    return self;
}

@end
