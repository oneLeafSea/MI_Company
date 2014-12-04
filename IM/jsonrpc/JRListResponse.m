//
//  JRListResponse.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRListResponse.h"

@implementation JRListResponse

- (BOOL)handleResult:(NSArray *) result {
    _data = result;
    return YES;
}

@end
