//
//  JRReqest.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRReqest.h"
#import "NSUUID+StringUUID.h"

@interface JRReqest() {
    
}

@end

@implementation JRReqest

- (instancetype) initWithMethod:(JRReqMethod *) m param:(JRReqParam *) param {
    
    if (self = [super init]) {
        _method = m;
        _param  = param;
        _requestID = [NSUUID uuid];
    }
    return self;
}

- (NSString *) key {
    return _param.key;
}

- (NSString *) iv {
    return _param.iv;
}


@end
