//
//  RTMessagesBubbleImageFactory.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RTMessagesBubbleImage.h"

@interface RTMessagesBubbleImageFactory : NSObject

- (instancetype)init;

- (instancetype)initWithBubbleImage:(UIImage *)bubbleImage capInsets:(UIEdgeInsets)capInsets;

- (RTMessagesBubbleImage *)outgoingMessagesBubbleImageWithColor:(UIColor *)color;

- (RTMessagesBubbleImage *)incomingMessagesBubbleImageWithColor:(UIColor *)color;

- (RTMessagesBubbleImage *)outgoingMessagesRoundCornerBubbleImageWithColor:(UIColor *)color;

- (RTMessagesBubbleImage *)incomingMessagesRoundCornerBubbleImageWithColor:(UIColor *)color;


@end
