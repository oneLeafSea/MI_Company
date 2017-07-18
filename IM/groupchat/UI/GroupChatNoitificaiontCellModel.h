//
//  GroupChatNoitificaiontCellModel.h
//  IM
//
//  Created by 郭志伟 on 15/9/14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupChatNoitificaiontCellModel : NSObject

@property(nonatomic, copy) NSString *msgid;
@property(nonatomic, copy) NSString *gname;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, assign) BOOL processed;
@property(nonatomic, copy) NSString *from;
@property(nonatomic, copy) NSString *to;
@property(nonatomic, copy) NSString *time;
@property(nonatomic, copy) NSString *notifyType;
@property(nonatomic, copy) NSString *gid;

@end
