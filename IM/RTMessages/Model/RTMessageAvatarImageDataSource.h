//
//  RTMessageAvatarImageDataSource.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RTMessageAvatarImageDataSource <NSObject>

@required

- (UIImage *)avatarImage;

- (UIImage *)avatarHighlightedImage;

- (UIImage *)avatarPlaceholderImage;

@end
