//
//  MainItemData.m
//  dongrun_beijing
//
//  Created by guozw on 14/11/6.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "MainItemData.h"

@implementation MainItemData

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imgName {
    if (self = [super init]) {
        _name = name;
        _imageName = imgName;
    }
    return self;
}

@end
