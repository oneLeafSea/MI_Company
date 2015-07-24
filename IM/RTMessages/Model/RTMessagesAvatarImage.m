//
//  RTMessagesAvatarImage.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesAvatarImage.h"

@implementation RTMessagesAvatarImage

#pragma mark - Initialization

+ (instancetype)avatarWithImage:(UIImage *)image
{
    NSParameterAssert(image != nil);
    
    return [[RTMessagesAvatarImage alloc] initWithAvatarImage:image
                                              highlightedImage:image
                                              placeholderImage:image];
}

+ (instancetype)avatarImageWithPlaceholder:(UIImage *)placeholderImage
{
    return [[RTMessagesAvatarImage alloc] initWithAvatarImage:nil
                                              highlightedImage:nil
                                              placeholderImage:placeholderImage];
}

- (instancetype)initWithAvatarImage:(UIImage *)avatarImage
                   highlightedImage:(UIImage *)highlightedImage
                   placeholderImage:(UIImage *)placeholderImage
{
    NSParameterAssert(placeholderImage != nil);
    
    self = [super init];
    if (self) {
        _avatarImage = avatarImage;
        _avatarHighlightedImage = highlightedImage;
        _avatarPlaceholderImage = placeholderImage;
    }
    return self;
}

- (id)init
{
    NSAssert(NO, @"%s is not a valid initializer for %@. Use %@ instead.",
             __PRETTY_FUNCTION__, [self class], NSStringFromSelector(@selector(initWithAvatarImage:highlightedImage:placeholderImage:)));
    return nil;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: avatarImage=%@, avatarHighlightedImage=%@, avatarPlaceholderImage=%@>",
            [self class], self.avatarImage, self.avatarHighlightedImage, self.avatarPlaceholderImage];
}

- (id)debugQuickLookObject
{
    return [[UIImageView alloc] initWithImage:self.avatarImage ?: self.avatarPlaceholderImage];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithAvatarImage:[UIImage imageWithCGImage:self.avatarImage.CGImage]
                                                 highlightedImage:[UIImage imageWithCGImage:self.avatarHighlightedImage.CGImage]
                                                 placeholderImage:[UIImage imageWithCGImage:self.avatarPlaceholderImage.CGImage]];
}

@end
