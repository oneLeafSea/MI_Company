//
//  AvatarVerTb.h
//  IM
//
//  Created by 郭志伟 on 15/9/2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FMDB.h>

@interface AvatarVerTb : NSObject

- (instancetype)initWithDbq:(FMDatabaseQueue *)dbq;

- (BOOL)updateVersion:(NSString *)version;
- (NSString *)getVersion;

@end
