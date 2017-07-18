//
//  GroupChatItem.m
//  IM
//
//  Created by 郭志伟 on 15-3-3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatItem.h"

@implementation GroupChatItem

- (instancetype)initWithUid:(NSString *)uid
                       name:(NSString *)name
                       rank:(GroupChatItemRank)rank {
    if (self = [super init]) {
        _uid = [uid copy];
        _name = [name copy];
        _rank = rank;
    }
    return self;
}

@end
