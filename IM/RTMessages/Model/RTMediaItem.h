//
//  RTMediaItem.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTMessageMediaData.h"

@interface RTMediaItem : NSObject <RTMessageMediaData, NSCoding, NSCopying>

@property (assign, nonatomic) BOOL appliesMediaViewMaskAsOutgoing;

- (instancetype)initWithMaskAsOutgoing:(BOOL)maskAsOutgoing;

- (void)clearCachedMediaViews;

@end
