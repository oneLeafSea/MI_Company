//
//  FCItemCommentsViewModel.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCItemCommentsViewModel.h"

@implementation FCItemCommentsViewModel

- (instancetype)init {
    if (self = [super init]) {
        self.fcicItemCellModels = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

@end
