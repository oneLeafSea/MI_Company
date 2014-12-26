//
//  IM.h
//  IM
//
//  Created by 郭志伟 on 14-12-26.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "IMConf.h"
#import "session.h"

@interface IM : NSObject

@property(nonatomic, strong) User   *user;
@property(nonatomic, strong) IMConf *cfg;






@end
