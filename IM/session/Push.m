//
//  Push.m
//  WH
//
//  Created by 郭志伟 on 14-10-14.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Push.h"
#import "Request.h"

static NSString *KKeyMsgID      = @"msgid";
static NSString *KKeyPushtype    = @"type";
static NSString *KKeyType       = @"type";
static NSString *KKeyTitle      = @"title";
static NSString *KKeyContent    = @"content";
static NSString *KKeyParams     = @"params";
static NSString *KKeyMsgTime    = @"msgtime";
static NSString *KKeyUser       = @"user";
static NSString *KKeyDevice     = @"device";
static NSString *KKeySid        = @"sid";


@interface Receipt : Request {
    NSDictionary *m_dict;
}

- (instancetype)initWithDict:(NSDictionary *)dict;
@end

@implementation Receipt


- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        m_dict = dict;
    }
    return self;
}


- (NSData *)pkgData {
    NSData *Data = [self bsonData:m_dict];
    return Data;
}

@end


@implementation Push

- (instancetype)init {
    if (self = [super init]) {
        self.msgType = MessageTypePush;
    }
    return self;
}


- (BOOL)parseData:(UInt32)type data:(NSData *)data {
    self.type = type;
    NSDictionary *dict = [self decodeBsonData:data];
    _msgID   = [dict objectForKey:KKeyMsgID];
    _pushType= [dict objectForKey:KKeyPushtype];
    _content = [dict objectForKey:KKeyContent];
    _params  = [dict objectForKey:KKeyParams];
    _msgtime = [dict objectForKey:KKeyMsgTime];
    _user    = [dict objectForKey:KKeyUser];
    _device  = [dict objectForKey:KKeyDevice];
    _sid     = [dict objectForKey:KKeySid];
    
    return YES;
}

- (void)returnReceipt:(Session *)sess {
    NSDictionary *dict = @{KKeyMsgID    : _msgID,
                           KKeyPushtype : _pushType,
                           KKeyMsgTime  : _msgtime,
                           KKeyUser     : _user,
                           KKeyDevice   : _device,
                           KKeySid      : _sid
                           };
    Receipt *recipt = [[Receipt alloc]initWithDict:dict];
    [sess post:recipt];
}

@end
