//
//  OsItem.h
//  IM
//
//  Created by 郭志伟 on 15-3-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OsItem : NSObject

- (instancetype)initWithUid:(NSString *)uid name:(NSString *)name org:(NSString *)org;

@property(nonatomic) NSString *uid;
@property(nonatomic) NSString *name;
@property(nonatomic) NSString *org;
@property(nonatomic) NSString *op;

@end
