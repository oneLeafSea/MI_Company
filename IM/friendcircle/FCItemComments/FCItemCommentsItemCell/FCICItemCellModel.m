//
//  FCICItemCellModel.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCICItemCellModel.h"
#import "AppDelegate.h"

@implementation FCICItemCellModel

- (BOOL)replied {
    if (self.repliedName.length > 0 && self.repliedUid.length > 0)
        return YES;
    return NO;
}

- (void)setUid:(NSString *)uid {
    _uid = [uid copy];
    if ([_uid isEqualToString:USER.uid]) {
        self.name = USER.name;
    } else {
        self.name = [USER.osMgr getItemInfoByUid:_uid].name;
    }
}

- (void)setRepliedUid:(NSString *)repliedUid {
    _repliedUid = repliedUid;
    if (repliedUid == nil) {
        _repliedName = nil;
        _repliedUid = nil;
        return;
    }
    _repliedUid = [_repliedUid copy];
    if ([_repliedUid isEqualToString:USER.uid]) {
        self.repliedName = USER.name;
    } else {
        self.repliedName = [USER.osMgr getItemInfoByUid:repliedUid].name;
    }
}

@end
