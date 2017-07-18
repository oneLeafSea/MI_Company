//
//  Relogin.h
//  IM
//
//  Created by 郭志伟 on 15-1-27.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Relogin : NSObject

+ (instancetype)instance;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *pwd;

@end
