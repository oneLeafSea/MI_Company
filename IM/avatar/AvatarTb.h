//
//  AvatarTb.h
//  IM
//
//  Created by 郭志伟 on 15/9/2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FMDB.h>

@interface AvatarTb : NSObject

- (instancetype)initWithDbq:(FMDatabaseQueue *)dbq;

- (BOOL)updateWithArray:(NSArray *)array;

- (BOOL)needUpdateForUid:(NSString *)uid;

- (void)updateAvatarSuccessWithUid:(NSString *)uid;

@end
