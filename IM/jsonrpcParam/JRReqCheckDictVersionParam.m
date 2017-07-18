//
//  JRReqCheckDictVersionParam.m
//  WH
//
//  Created by guozw on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRReqCheckDictVersionParam.h"
#import "LogLevel.h"
#import "NSJSONSerialization+StrDictConverter.h"
#import "NSUUID+StringUUID.h"

typedef NS_ENUM(NSUInteger, ReqCode) {
    ReqCodeDictVersion          = 1,
    ReqCodeDictDownload         = 2,
    ReqCodeAppVersion           = 3,
    ReqCodeAppDownload          = 4
};

static const NSString *kKeyReqCode   = @"reqcode";
static const NSString *kKeyQid       = @"qid";
static const NSString *kKeyToken     = @"token";
static const NSString *kKeyTimeStamp = @"timestamp";
static const NSString *kKeySignature = @"signature";
static const NSString *kKeyParam     = @"params";

@implementation JRReqCheckDictVersionParam

- (instancetype) initWithToken:(NSString *)token key:(NSString *)key iv:(NSString *)iv {
    if (self = [super initWithQid:@"" token:token key:key iv:iv]) {
        
    }
    return self;
}

- (NSDictionary *) package {
    
    NSDictionary *dictParams = [self packDictParam];
    if (!dictParams) {
        return nil;
    }
    
    NSDictionary *params = @{
                              kKeyReqCode:@1,
                              kKeyQid : [NSUUID uuid],
                              kKeyToken: self.token,
                              kKeyTimeStamp: self.timestamp,
                              kKeySignature : @"rooten.Iphone.Signature",
                              kKeyParam : dictParams,
                              };
    DDLogInfo(@"%@", params);
    
    return params;
}


- (NSDictionary *) packDictParam {
    
    NSDictionary *dicts = @{
                        @"BY" : @"0"
                        };
    
    NSString *js = [NSJSONSerialization jsonStringFromDict:dicts];
    NSDictionary *dicParam = @{
                            @"type":@"iphone",
                            @"dicts": js
                            };
    
    return dicParam;
}



@end
