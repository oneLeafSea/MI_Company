//
//  FCICItemCellModel.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCICItemCellModel.h"

@implementation FCICItemCellModel

- (BOOL)replied {
    if (self.repliedName.length > 0 && self.repliedUid.length > 0)
        return YES;
    return NO;
}

@end
