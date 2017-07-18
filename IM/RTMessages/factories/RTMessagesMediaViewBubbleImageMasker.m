//
//  RTMessagesMediaViewBubbleImageMasker.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesMediaViewBubbleImageMasker.h"

#import "RTMessagesBubbleImageFactory.h"

@interface RTMessagesMediaViewBubbleImageMasker ()

- (void)rt_maskView:(UIView *)view withImage:(UIImage *)image;

@end

@implementation RTMessagesMediaViewBubbleImageMasker

- (instancetype)init
{
    return [self initWithBubbleImageFactory:[[RTMessagesBubbleImageFactory alloc] init]];
}

- (instancetype)initWithBubbleImageFactory:(RTMessagesBubbleImageFactory *)bubbleImageFactory
{
    NSParameterAssert(bubbleImageFactory != nil);
    
    self = [super init];
    if (self) {
        _bubbleImageFactory = bubbleImageFactory;
    }
    return self;
}

#pragma mark - View masking

- (void)applyOutgoingBubbleImageMaskToMediaView:(UIView *)mediaView
{
    RTMessagesBubbleImage *bubbleImageData = [self.bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    [self rt_maskView:mediaView withImage:[bubbleImageData messageBubbleImage]];
}

- (void)applyIncomingBubbleImageMaskToMediaView:(UIView *)mediaView
{
    RTMessagesBubbleImage *bubbleImageData = [self.bubbleImageFactory incomingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    [self rt_maskView:mediaView withImage:[bubbleImageData messageBubbleImage]];
}

+ (void)applyBubbleImageMaskToMediaView:(UIView *)mediaView isOutgoing:(BOOL)isOutgoing
{
    RTMessagesMediaViewBubbleImageMasker *masker = [[RTMessagesMediaViewBubbleImageMasker alloc] init];
    
    if (isOutgoing) {
        [masker applyOutgoingBubbleImageMaskToMediaView:mediaView];
    }
    else {
        [masker applyIncomingBubbleImageMaskToMediaView:mediaView];
    }
}

#pragma mark - Private

- (void)rt_maskView:(UIView *)view withImage:(UIImage *)image
{
    NSParameterAssert(view != nil);
    NSParameterAssert(image != nil);
    
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 2.0f, 2.0f);
    
    view.layer.mask = imageViewMask.layer;
}


@end
