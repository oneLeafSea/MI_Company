//
//  RTMessagesMediaViewBubbleImageMasker.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RTMessagesBubbleImageFactory;

@interface RTMessagesMediaViewBubbleImageMasker : NSObject

@property (strong, nonatomic, readonly) RTMessagesBubbleImageFactory *bubbleImageFactory;

- (instancetype)init;

- (instancetype)initWithBubbleImageFactory:(RTMessagesBubbleImageFactory *)bubbleImageFactory;

- (void)applyOutgoingBubbleImageMaskToMediaView:(UIView *)mediaView;

- (void)applyIncomingBubbleImageMaskToMediaView:(UIView *)mediaView;

+ (void)applyBubbleImageMaskToMediaView:(UIView *)mediaView isOutgoing:(BOOL)isOutgoing;

@end
