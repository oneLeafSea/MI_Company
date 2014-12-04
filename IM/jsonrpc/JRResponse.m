//
//  JRResponse.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRResponse.h"





@implementation JRResponse

- (instancetype)initWithType:(JRResponseType)type ext:(NSDictionary *)ext timestamp:(NSString *)timestamp {
    
    if (self = [super init]) {
        _type = type;
        _ext  = ext;
        _timestamp = timestamp;
    }
    return self;
}

@end
