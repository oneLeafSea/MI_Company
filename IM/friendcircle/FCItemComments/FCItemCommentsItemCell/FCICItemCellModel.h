//
//  FCICItemCellModel.h
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCICItemCellModel : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *uid;
@property(nonatomic, copy) NSString *repliedName;
@property(nonatomic, copy) NSString *repliedUid;
@property(nonatomic, copy) NSString *time;
@property(nonatomic, copy) NSString *replyId;
@property(nonatomic, copy) NSString *belongToId;

@property(nonatomic, copy) NSString *content;

@property(nonatomic, readonly) BOOL replied;

@end
