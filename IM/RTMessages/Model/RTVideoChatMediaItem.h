//
//  RTVideoChatMediaItem.h
//  IM
//
//  Created by 郭志伟 on 15/9/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMediaItem.h"

@interface RTVideoChatMediaItem : RTMediaItem<RTMessageMediaData>

- (instancetype)initWithTip:(NSString *)tip;

@property(copy, nonatomic)NSString *tip;

@end
