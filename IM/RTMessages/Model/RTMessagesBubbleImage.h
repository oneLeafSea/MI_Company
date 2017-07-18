//
//  RTMessagesBubbleImage.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTMessageBubbleImageDataSource.h"

@interface RTMessagesBubbleImage : NSObject <RTMessageBubbleImageDataSource, NSCopying>

@property (strong, nonatomic, readonly) UIImage *messageBubbleImage;

@property (strong, nonatomic, readonly) UIImage *messageBubbleHighlightedImage;

- (instancetype)initWithMessageBubbleImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage;

@end
