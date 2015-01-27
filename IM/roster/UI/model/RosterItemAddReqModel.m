//
//  RosterItemAddReqModel.m
//  IM
//
//  Created by 郭志伟 on 15-1-23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemAddReqModel.h"

@implementation RosterItemAddReqModel

- (instancetype) initWithReqList: (NSArray *)reqList {
    if (self = [super init]) {
        _reqList = reqList;
    }
    return self;
}

@end
