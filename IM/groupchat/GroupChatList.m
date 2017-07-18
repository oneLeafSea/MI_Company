//
//  GroupChatList.m
//  IM
//
//  Created by 郭志伟 on 15-3-2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatList.h"
#import "GroupChat.h"

@implementation GroupChatList

- (instancetype)initWithGrpInfo:(NSArray *)info {
    if (self = [super init]) {
        if (![self parseInfo:info]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)parseInfo:(NSArray *)info {
    __block BOOL ret = YES;
    __block NSMutableArray *grpList = [[NSMutableArray alloc] init];
    [info enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *arr = obj;
        __block NSString *gid = nil;
        __block NSString *gname = nil;
        __block NSString *uid = nil;
        __block NSString *uname = nil;
        __block NSString *time = nil;
        __block GropuChatype type = GropuChatypePrivate;
        __block BOOL exit = YES;
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *n = [obj objectForKey:@"n"];
            NSString *v = [obj objectForKey:@"v"];
            if ([n isEqualToString:@"gid"]) {
                gid = [v copy];
            }
            if ([n isEqualToString:@"gname"]) {
                gname = [v copy];
            }
            if ([n isEqualToString:@"uid"]) {
                uid = [v copy];
            }
            if ([n isEqualToString:@"uname"]) {
                uname = [v copy];
            }
            if ([n isEqualToString:@"time"]) {
                time = [v copy];
            }
            if ([n isEqualToString:@"type"]) {
                if ([v isEqualToString:@"2"]) {
                    type = GropuChatypePublic;
                }
            }
            if ([n isEqualToString:@"exit"]) {
                if ([v isEqualToString:@"0"]) {
                    exit = NO;
                }
            }
        }];
        GroupChat * grp = [[GroupChat alloc] initWithGid:gid
                                                   gname:gname
                                               creatorId:uid
                                             creatorName:uname
                                                    type:type
                                                    exit:exit];
        if (grp) {
            [grpList addObject:grp];
        } else {
            ret = NO;
            *stop = YES;
        }
    }];
    if (ret) {
        _grpChatList = grpList;
    }
    return ret;
}

@end
