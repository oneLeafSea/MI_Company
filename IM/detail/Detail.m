//
//  Detail.m
//  IM
//
//  Created by 郭志伟 on 15-3-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "Detail.h"

@implementation Detail

- (instancetype)initWithResp:(JRListResponse *)resp {
    if (self = [super init]) {
        if (![self parseResp:resp]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)parseResp:(JRListResponse *)listResp {
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    __block BOOL ret = YES;
    NSArray *res = listResp.data;
    [res enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *n = [obj objectForKey:@"n"];
        NSString *v = [obj objectForKey:@"v"];
        if (n != nil && v != nil) {
            [dict setObject:[v copy] forKey:[n copy]];
        }
    }];
    if (ret) {
        _data = dict;
    }
    return ret;
}

@end
