//
//  RTMorePanelItemMode.m
//  IM
//
//  Created by 郭志伟 on 15/7/16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMorePanelItemMode.h"

@implementation RTMorePanelItemMode

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image target:(id)target selector:(SEL)selector {
    if (self = [super init]) {
        _title = [title copy];
        _image = image;
        _selector = selector;
        _target = target;
    }
    return self;
}

@end
