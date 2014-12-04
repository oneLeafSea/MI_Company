//
//  LoginRequest.h
//  WH
//
//  Created by guozw on 14-10-15.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Request.h"

@protocol LoginRequestDelegate;


@interface LoginRequest : Request

- (instancetype)initWithUserId:(NSString *)userId pwd:(NSString *)pwd;

@end

