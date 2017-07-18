//
//  GroupChatItem.h
//  IM
//
//  Created by 郭志伟 on 15-3-3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt32, GroupChatItemRank) {
    
    GroupChatItemRankMember,
    GroupChatItemRankAdmin
};

@interface GroupChatItem : NSObject

- (instancetype)initWithUid:(NSString *)uid
                       name:(NSString *)name
                       rank:(GroupChatItemRank)rank;

@property(nonatomic) NSString *uid;
@property(nonatomic) NSString *name;
@property(nonatomic) GroupChatItemRank rank;

@end
