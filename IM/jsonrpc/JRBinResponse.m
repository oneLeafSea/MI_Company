//
//  JRBinResponse.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRBinResponse.h"

@implementation JRBinResponse

- (BOOL)handleResult:(NSData *) result {
    _data = result;
    return YES;
}

@end
