//
//  JSQVideoChatMediaItem.h
//  IM
//
//  Created by 郭志伟 on 15/4/24.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "JSQMediaItem.h"

@interface JSQVideoChatMediaItem : JSQMediaItem <JSQMessageMediaData>

- (instancetype)initWithTip:(NSString *)tip;

@property(copy, nonatomic)NSString *tip;

@end
