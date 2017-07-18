//
//  RTVideoMediaItem.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMediaItem.h"

@interface RTVideoMediaItem : RTMediaItem <RTMessageMediaData, NSCoding, NSCopying>

@property (nonatomic, strong) NSURL *fileURL;

@property (nonatomic, assign) BOOL isReadyToPlay;

- (instancetype)initWithFileURL:(NSURL *)fileURL isReadyToPlay:(BOOL)isReadyToPlay;

@end
