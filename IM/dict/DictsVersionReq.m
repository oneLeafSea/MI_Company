//
//  DictVersionReq.m
//  WH
//
//  Created by guozw on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "DictsVersionReq.h"
#import "NSJSONSerialization+StrDictConverter.h"

@interface DictsVersionReq() {
    NSMutableDictionary *m_dictInfo;
}

@end

@implementation DictsVersionReq

- (instancetype) initWithToken:(NSString *)token url:(NSString *)url org:(NSString *)org {
    if (self = [super initWithToken:token url:url org:org]) {
        m_dictInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSDictionary *)paramKeyVal {
    NSString *jsStr = [NSJSONSerialization jsonStringFromDict:m_dictInfo];
    NSDictionary *ret =     @{
                              @"org": self.org,
                              @"dicts": jsStr
                              };

    return ret;
}

- (void)addDictInfo:(NSString *)dictName version:(NSString *)version {
    [m_dictInfo setValue:version forKey:dictName];
}

- (NSUInteger)reqCode {
    return ReqCodeDictVersion;
}

@end
