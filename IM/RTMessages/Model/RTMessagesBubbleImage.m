//
//  RTMessagesBubbleImage.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesBubbleImage.h"

@implementation RTMessagesBubbleImage

- (id)init
{
    NSAssert(NO, @"%s is not a valid initializer for %@. Use %@ instead.",
             __PRETTY_FUNCTION__, [self class], NSStringFromSelector(@selector(initWithMessageBubbleImage:highlightedImage:)));
    return nil;
}


- (instancetype)initWithMessageBubbleImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    NSParameterAssert(image != nil);
    NSParameterAssert(highlightedImage != nil);
    
    self = [super init];
    if (self) {
        _messageBubbleImage = image;
        _messageBubbleHighlightedImage = highlightedImage;
    }
    return self;
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: messageBubbleImage=%@, messageBubbleHighlightedImage=%@>",
            [self class], self.messageBubbleImage, self.messageBubbleHighlightedImage];
}

- (id)debugQuickLookObject {
    return [[UIImageView alloc] initWithImage:self.messageBubbleImage highlightedImage:self.messageBubbleHighlightedImage];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithMessageBubbleImage:[UIImage imageWithCGImage:self.messageBubbleImage.CGImage]
                                                        highlightedImage:[UIImage imageWithCGImage:self.messageBubbleHighlightedImage.CGImage]];
}


@end
