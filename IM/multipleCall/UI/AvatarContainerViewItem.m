//
//  AvatarContainerViewItem.m
//  IM
//
//  Created by 郭志伟 on 15/5/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "AvatarContainerViewItem.h"

@implementation AvatarContainerViewItem

- (instancetype)initWithUid:(NSString *)uid
                       name:(NSString *)name
                  imgStrUrl:(NSString *)imgStrUrl {
    if (self = [super init]) {
        self.uid = uid;
        self.name = name;
        self.imgStrUrl = imgStrUrl;
    }
    return self;
}

@end
