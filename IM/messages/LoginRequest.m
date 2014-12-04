//
//  LoginRequest.m
//  WH
//
//  Created by guozw on 14-10-15.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "LoginRequest.h"
#import "ObjCMongoDB.h"
#import "MessageConstants.h"
#import "LogLevel.h"
#import "NSJSONSerialization+StrDictConverter.h"

static const NSString *kUserId = @"user";
static const NSString *kPwd    = @"pwd";


@interface LoginRequest() {
    NSString *m_userId;
    NSString *m_pwd;
}

@end

@implementation LoginRequest

- (instancetype)init {
    if (self = [super init]) {
        self.type = MSG_LOGIN;
    }
    return self;
}

- (instancetype)initWithUserId:(NSString *)userId pwd:(NSString *)pwd {
    if (self = [self init]) {
        m_userId = userId;
        m_pwd    = pwd;
    }
    return self;
}


- (NSData *)pkgData {
    
    NSDictionary *loginDict = @{kMsgQid   : self.qid,
                                kUserId   : m_userId,
                                kPwd      : m_pwd,
                                kDevice   : kDeviceType
                                };
    DDLogInfo(@"--> %@", loginDict);

    NSData *data = [self jsonDataFromDict:loginDict];
    return data;
}



@end
