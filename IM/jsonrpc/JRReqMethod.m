//
//  JRMethod.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRReqMethod.h"

@implementation JRReqMethod

- (instancetype) initWithService:(const NSString *)svc {
    if (self = [super init]) {
        _service = svc;
    }
    return self;
}

- (NSString *)method {
    NSString *m = [NSString stringWithFormat:@"%@%@", _service, @".Do"];
    return m;
}

+ (NSString *) Method:(NSString *)service {
    JRReqMethod *method = [[JRReqMethod alloc] initWithService:service];
    NSString *m = [method method];
    return m;
}

@end
