//
//  GroupChatList.h
//  IM
//
//  Created by 郭志伟 on 15-3-2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupChatList : NSObject

- (instancetype)initWithGrpInfo:(NSArray *)info;

@property(nonatomic, strong) NSArray *grpChatList;

@end
