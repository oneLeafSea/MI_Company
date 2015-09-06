//
//  RTMessagesBubbleImageFactory.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesBubbleImageFactory.h"

#import "UIImage+RTMessages.h"
#import "UIColor+RTMessages.h"

@interface RTMessagesBubbleImageFactory()

@property (strong, nonatomic, readonly) UIImage *bubbleImage;
@property (assign, nonatomic, readonly) UIEdgeInsets capInsets;

- (UIEdgeInsets)rt_centerPointEdgeInsetsForImageSize:(CGSize)bubbleImageSize;

- (RTMessagesBubbleImage *)rt_messagesBubbleImageWithColor:(UIColor *)color flippedForIncoming:(BOOL)flippedForIncoming;

- (UIImage *)rt_horizontallyFlippedImageFromImage:(UIImage *)image;

- (UIImage *)rt_stretchableImageFromImage:(UIImage *)image withCapInsets:(UIEdgeInsets)capInsets;

@end

@implementation RTMessagesBubbleImageFactory

- (instancetype)initWithBubbleImage:(UIImage *)bubbleImage capInsets:(UIEdgeInsets)capInsets {
    NSParameterAssert(bubbleImage != nil);
    
    self = [super init];
    if (self) {
        _bubbleImage = bubbleImage;
        
        if (UIEdgeInsetsEqualToEdgeInsets(capInsets, UIEdgeInsetsZero)) {
            _capInsets = [self rt_centerPointEdgeInsetsForImageSize:bubbleImage.size];
        }
        else {
            _capInsets = capInsets;
        }
    }
    return self;
}

- (instancetype)init {
    return [self initWithBubbleImage:[UIImage rt_bubbleCompactImage] capInsets:UIEdgeInsetsZero];
}

- (void)dealloc {
    _bubbleImage = nil;
}

#pragma mark - Public

- (RTMessagesBubbleImage *)outgoingMessagesBubbleImageWithColor:(UIColor *)color
{
    return [self rt_messagesBubbleImageWithColor:color flippedForIncoming:NO];
}

- (RTMessagesBubbleImage *)incomingMessagesBubbleImageWithColor:(UIColor *)color
{
    return [self rt_messagesBubbleImageWithColor:color flippedForIncoming:YES];
}


- (RTMessagesBubbleImage *)outgoingMessagesRoundCornerBubbleImageWithColor:(UIColor *)color {
    return nil;
}

- (RTMessagesBubbleImage *)incomingMessagesRoundCornerBubbleImageWithColor:(UIColor *)color {
    return nil;
}

#pragma mark - Private
- (UIEdgeInsets)rt_centerPointEdgeInsetsForImageSize:(CGSize)bubbleImageSize {
    CGPoint center = CGPointMake(bubbleImageSize.width / 2.0f, bubbleImageSize.height / 2.0f);
    return UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
}

- (RTMessagesBubbleImage *)rt_messagesBubbleImageWithColor:(UIColor *)color flippedForIncoming:(BOOL)flippedForIncoming
{
    NSParameterAssert(color != nil);
    
    UIImage *normalBubble = [self.bubbleImage rt_imageMaskedWithColor:color];
    UIImage *highlightedBubble = [self.bubbleImage rt_imageMaskedWithColor:[color rt_colorByDarkeningColorWithValue:0.12f]];
    
    if (flippedForIncoming) {
        normalBubble = [self rt_horizontallyFlippedImageFromImage:normalBubble];
        highlightedBubble = [self rt_horizontallyFlippedImageFromImage:highlightedBubble];
    }
    
    normalBubble = [self rt_stretchableImageFromImage:normalBubble withCapInsets:self.capInsets];
    highlightedBubble = [self rt_stretchableImageFromImage:highlightedBubble withCapInsets:self.capInsets];
    
    return [[RTMessagesBubbleImage alloc] initWithMessageBubbleImage:normalBubble highlightedImage:highlightedBubble];
}

- (UIImage *)rt_horizontallyFlippedImageFromImage:(UIImage *)image {
    return [UIImage imageWithCGImage:image.CGImage
                               scale:image.scale
                         orientation:UIImageOrientationUpMirrored];
}

- (UIImage *)rt_stretchableImageFromImage:(UIImage *)image withCapInsets:(UIEdgeInsets)capInsets {
    return [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}

@end
