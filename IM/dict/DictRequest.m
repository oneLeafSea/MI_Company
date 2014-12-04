//
//  DictRequest.m
//  WH
//
//  Created by guozw on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "DictRequest.h"
#import "NSUUID+StringUUID.h"
#import "LogLevel.h"
#import "NSDate+Common.h"
#import "NSJSONSerialization+StrDictConverter.h"

static const NSString *kKeyReqCode   = @"reqcode";
static const NSString *kKeyQid       = @"qid";
static const NSString *kKeyToken     = @"token";
static const NSString *kKeyTimeStamp = @"timestamp";
static const NSString *kKeySignature = @"signature";
static const NSString *kKeyParam     = @"params";

@implementation DictRequest

- (instancetype)initWithToken:(NSString *)token url:(NSString *) url  org:(NSString *)org {
    if (self = [super init]) {
        _token = token;
        _url = [NSURL URLWithString:url];
        _org = org;
    }
    return self;
}

- (NSString *)resultId {
    return [NSUUID uuid];
}

- (NSDictionary *)paramKeyVal {
    DDLogWarn(@"Param key should be override.");
    return nil;
}


- (NSDictionary *)params {
    NSDictionary *ParamVal = [self paramKeyVal];;
    if (ParamVal == nil) {
        return nil;
    }
    NSDictionary *params = @{
                             kKeyReqCode:@(self.reqCode),
                             kKeyQid : [NSUUID uuid],
                             kKeyToken: self.token,
                             kKeyTimeStamp: [[NSDate Now] formatWith:nil],
                             kKeySignature : @"rooten.Iphone.Signature",
                             kKeyParam : ParamVal
                             };

    DDLogInfo(@"%@", params);
    return params;
}

- (NSString *)method {
    return @"download.Do";
}

@end
