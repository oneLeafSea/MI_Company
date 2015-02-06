//
//  ChatMessageMorePanelItemMode.m
//  IM
//
//  Created by 郭志伟 on 15-2-4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageMorePanelItemMode.h"

@interface ChatMessageMorePanelItemMode() {
   
}
@end

@implementation ChatMessageMorePanelItemMode

- (instancetype) initWithTitle:(NSString *)title imageName:(NSString *)imageName target:(id)target selector:(SEL)selector {
    if (self = [super init]) {
        _title = title;
        _imageName = imageName;
        _selector = selector;
        _target = target;
    }
    return self;
}

@end
