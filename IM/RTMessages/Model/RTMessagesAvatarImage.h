//
//  RTMessagesAvatarImage.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMediaItem.h"

#import <UIKit/UIKit.h>

#import "RTMessageAvatarImageDataSource.h"

@interface RTMessagesAvatarImage : RTMediaItem <RTMessageAvatarImageDataSource, NSCopying>

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, strong) UIImage *avatarHighlightedImage;

@property (nonatomic, strong, readonly) UIImage *avatarPlaceholderImage;

+ (instancetype)avatarWithImage:(UIImage *)image;

+ (instancetype)avatarImageWithPlaceholder:(UIImage *)placeholderImage;

- (instancetype)initWithAvatarImage:(UIImage *)avatarImage
                   highlightedImage:(UIImage *)highlightedImage
                   placeholderImage:(UIImage *)placeholderImage;

@end
