//
//  GroupChat.m
//  IM
//
//  Created by 郭志伟 on 15-3-2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChat.h"
#import "RosterItem.h"
#import "GroupChatItem.h"
// 1是管理员 0是普通成员
@implementation GroupChat


- (instancetype)initWithGid:(NSString *)gid
                      gname:(NSString *)gname
                  creatorId:(NSString *)creatorId
                creatorName:(NSString *)creatorName
                       type:(GropuChatype)type
                       exit:(BOOL)exit {
    if (self = [super init]) {
        _gid = [gid copy];
        _gname = [gname copy];
        _creatorId = [creatorId copy];
        _creatorName = [creatorName copy];
        _type = type;
        _exit = exit;
    }
    return self;
}

- (BOOL)parseItems:(NSArray *)result {
    __block BOOL ret = YES;
    __block NSMutableArray *items = [[NSMutableArray alloc] init];
    [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *item = obj;
        __block NSString *uid = nil;
        __block NSString *fname = nil;
        __block NSString *rank = nil;
        
        [item enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *n = [obj objectForKey:@"n"];
            NSString *v = [obj objectForKey:@"v"];
            if ([n isEqualToString:@"userid"]) {
                uid = [v copy];
            }
            
            if ([n isEqualToString:@"fname"]) {
                fname = [v copy];
            }
            
            if ([n isEqualToString:@"right"]) {
                rank = [v copy];
            }
            
        }];
        GroupChatItem *gItem = [[GroupChatItem alloc] initWithUid:uid name:fname rank:[rank intValue]];
        if (gItem) {
            [items addObject:gItem];
        } else {
            ret = NO;
            *stop = YES;
        }
    }];
    if (ret) {
        _items = items;
    }
    return ret;
}

@end
