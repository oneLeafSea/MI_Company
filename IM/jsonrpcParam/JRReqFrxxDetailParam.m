//
//  JRReqFrxxDetailParam.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRReqFrxxDetailParam.h"

@implementation JRReqFrxxDetailParam

- (instancetype)initWithToken:(NSString *)token key:(NSString *)key iv:(NSString *)iv {
    if (self = [super initWithQid:@"QID_FRXX_DETAIL" token:token key:key iv:iv]) {
        
    }
    return self;
}

- (NSDictionary *)JRReqParamData {
    NSDictionary *dict = @{
                           @"frbh":@"19"
                           };
    return dict;
}
@end
