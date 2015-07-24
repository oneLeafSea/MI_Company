//
//  RTMessageBubbleImageDataSource.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RTMessageBubbleImageDataSource <NSObject>

@required

- (UIImage *)messageBubbleImage;

- (UIImage *)messageBubbleHighlightedImage;

@end
