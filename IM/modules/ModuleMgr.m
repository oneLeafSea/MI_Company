//
//  ModuleMgr.m
//  dongrun_beijing
//
//  Created by guozw on 14-11-5.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "ModuleMgr.h"
static NSString *kXmlName = @"app.xml";

@implementation ModuleMgr

- (instancetype) init {
    if (self = [super init]) {
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL) setup {
    _root = [[ModuleRoot alloc]initWithXmlFileName:kXmlName];
    if (!_root) {
        return NO;
    }
    return YES;
}


@end
