//
//  DictRequest.h
//  WH
//
//  Created by guozw on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *
 **/

typedef NS_ENUM(NSUInteger, ReqCode) {
    ReqCodeDictVersion          = 1,
    ReqCodeDictDownload         = 2,
    ReqCodeAppVersion           = 3,
    ReqCodeAppDownload          = 4
};

@interface DictRequest : NSObject

- (instancetype)initWithToken:(NSString *)token url:(NSString *) url org:(NSString *)org;

- (NSDictionary *)paramKeyVal;

@property(readonly) NSURL        *url;
@property(readonly) NSDictionary *params;
@property(readonly) NSString     *method;
@property(readonly) NSString     *resultId;
@property(readonly) NSString     *token;
@property(readonly) NSUInteger   reqCode;
@property(readonly) NSString     *org;

@end
