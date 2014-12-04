//
//  JRReqParam.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRReqParam : NSObject

- (instancetype)initWithQid:(NSString *)qid
                      token:(NSString *)token
                        key:(NSString *)key
                         iv:(NSString *)iv;


- (NSDictionary *) package;

- (NSDictionary *) JRReqParamData;

@property(readonly)                 NSString *qid;
@property(nonatomic)                NSString *token;
@property(nonatomic, readonly)      NSString *timestamp;
@property(nonatomic, readonly)      NSString *signature;
@property(readonly)                 NSString *encrypt;

@property(readonly)                 NSString *key;
@property(readonly)                 NSString *iv;


@end
