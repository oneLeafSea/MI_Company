//
//  JRReqParam.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRReqParam.h"
#import "Encrypt.h"
#import "LogLevel.h"
#import "NSJSONSerialization+StrDictConverter.h"
#import "NSDate+Common.h"


static const NSString *kKeyQid       = @"qid";
static const NSString *kKeyToken     = @"token";
static const NSString *kKeyTimeStamp = @"timestamp";
static const NSString *kKeySignature = @"signature";
static const NSString *kKeyData      = @"data";
static const NSString *kKeyEncrypt   = @"encrypt";

@interface JRReqParam() {
    
    NSDictionary *m_data;
    
}

@end

@implementation JRReqParam

- (instancetype)initWithQid:(NSString *)qid token:(NSString *)token key:(NSString *)key iv:(NSString *)iv {
    if (self = [super init]) {
        _qid = qid;
        _token = token;
        _key = key;
        _iv  = iv;
        _timestamp = [[NSDate Now] formatWith:nil];
        _params = [[NSMutableDictionary alloc] init];
        m_data = nil;
    }
    return self;
}

- (NSDictionary *) package {
    
    NSDictionary *params = nil;
    if (self.params.count > 0) {
        NSString *strData = [NSJSONSerialization jsonStringFromDict:self.params];
        
        NSError *err = nil;
        NSString *base64Data = [Encrypt encodeWithKey:self.key iv:self.iv data:[strData dataUsingEncoding:NSUTF8StringEncoding] error:&err];
        
        if (err) {
            DDLogError(@"encode JReqParam Data:%@", err);
        }
        params = @{ kKeyQid : self.qid,
                                  kKeyToken: self.token,
                                  kKeyTimeStamp: self.timestamp,
                                  kKeySignature : @"rooten.Iphone.Signature",
                                  kKeyData : base64Data,
                                  kKeyEncrypt : @YES
                                  };
    } else {
        params = @{ kKeyQid : self.qid,
                    kKeyToken: self.token,
                    kKeyTimeStamp: self.timestamp,
                    kKeySignature : @"rooten.Iphone.Signature",
                    kKeyEncrypt : @YES
                    };
    }
    
    return params;
}

- (NSDictionary *) JRReqParamData {
    return nil;
}

@end
