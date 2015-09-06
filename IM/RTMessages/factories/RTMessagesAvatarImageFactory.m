//
//  RTMessagesAvatarImageFactory.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesAvatarImageFactory.h"

#import "UIColor+RTMessages.h"

@interface RTMessagesAvatarImageFactory()

+ (UIImage *)rt_circularImage:(UIImage *)image
                 withDiameter:(NSUInteger)diameter
             highlightedColor:(UIColor *)highlightedColor;

+ (UIImage *)rt_imageWitInitials:(NSString *)initials
                 backgroundColor:(UIColor *)backgroundColor
                       textColor:(UIColor *)textColor
                            font:(UIFont *)font
                        diameter:(NSUInteger)diameter;

@end

@implementation RTMessagesAvatarImageFactory

#pragma mark - Public
+ (RTMessagesAvatarImage *)avatarImageWithPlaceholder:(UIImage *)placeholderImage diameter:(NSUInteger)diameter
{
    UIImage *circlePlaceholderImage = [RTMessagesAvatarImageFactory rt_circularImage:placeholderImage
                                                                          withDiameter:diameter
                                                                      highlightedColor:nil];
    
    return [RTMessagesAvatarImage avatarImageWithPlaceholder:circlePlaceholderImage];
}

+ (RTMessagesAvatarImage *)avatarImageWithImage:(UIImage *)image diameter:(NSUInteger)diameter
{
    UIImage *avatar = [RTMessagesAvatarImageFactory circularAvatarImage:image withDiameter:diameter];
    UIImage *highlightedAvatar = [RTMessagesAvatarImageFactory circularAvatarHighlightedImage:image withDiameter:diameter];
    
    return [[RTMessagesAvatarImage alloc] initWithAvatarImage:avatar
                                              highlightedImage:highlightedAvatar
                                              placeholderImage:avatar];
}

+ (UIImage *)circularAvatarImage:(UIImage *)image withDiameter:(NSUInteger)diameter
{
    return [RTMessagesAvatarImageFactory rt_circularImage:image
                                               withDiameter:diameter
                                           highlightedColor:nil];
}

+ (UIImage *)circularAvatarHighlightedImage:(UIImage *)image withDiameter:(NSUInteger)diameter
{
    return [RTMessagesAvatarImageFactory rt_circularImage:image
                                               withDiameter:diameter
                                           highlightedColor:[UIColor colorWithWhite:0.1f alpha:0.3f]];
}

+ (RTMessagesAvatarImage *)avatarImageWithUserInitials:(NSString *)userInitials
                                        backgroundColor:(UIColor *)backgroundColor
                                              textColor:(UIColor *)textColor
                                                   font:(UIFont *)font
                                               diameter:(NSUInteger)diameter
{
    UIImage *avatarImage = [RTMessagesAvatarImageFactory rt_imageWitInitials:userInitials
                                                               backgroundColor:backgroundColor
                                                                     textColor:textColor
                                                                          font:font
                                                                      diameter:diameter];
    
    UIImage *avatarHighlightedImage = [RTMessagesAvatarImageFactory rt_circularImage:avatarImage
                                                                          withDiameter:diameter
                                                                      highlightedColor:[UIColor colorWithWhite:0.1f alpha:0.3f]];
    
    return [[RTMessagesAvatarImage alloc] initWithAvatarImage:avatarImage
                                              highlightedImage:avatarHighlightedImage
                                              placeholderImage:avatarImage];
}

+ (RTMessagesAvatarImage *)roundCornerAvatarImage:(UIImage *)image {
    RTMessagesAvatarImage *avatarImg = [[RTMessagesAvatarImage alloc] initWithAvatarImage:image highlightedImage:image placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    return avatarImg;
}

#pragma mark - Private

+ (UIImage *)rt_imageWitInitials:(NSString *)initials
                  backgroundColor:(UIColor *)backgroundColor
                        textColor:(UIColor *)textColor
                             font:(UIFont *)font
                         diameter:(NSUInteger)diameter
{
    NSParameterAssert(initials != nil);
    NSParameterAssert(backgroundColor != nil);
    NSParameterAssert(textColor != nil);
    NSParameterAssert(font != nil);
    NSParameterAssert(diameter > 0);
    
    CGRect frame = CGRectMake(0.0f, 0.0f, diameter, diameter);
    
    NSDictionary *attributes = @{ NSFontAttributeName : font,
                                  NSForegroundColorAttributeName : textColor };
    
    CGRect textFrame = [initials boundingRectWithSize:frame.size
                                              options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                           attributes:attributes
                                              context:nil];
    
    CGPoint frameMidPoint = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    CGPoint textFrameMidPoint = CGPointMake(CGRectGetMidX(textFrame), CGRectGetMidY(textFrame));
    
    CGFloat dx = frameMidPoint.x - textFrameMidPoint.x;
    CGFloat dy = frameMidPoint.y - textFrameMidPoint.y;
    CGPoint drawPoint = CGPointMake(dx, dy);
    UIImage *image = nil;
    
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, frame);
        [initials drawAtPoint:drawPoint withAttributes:attributes];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
    }
    UIGraphicsEndImageContext();
    
    return [RTMessagesAvatarImageFactory rt_circularImage:image withDiameter:diameter highlightedColor:nil];
}

+ (UIImage *)rt_circularImage:(UIImage *)image withDiameter:(NSUInteger)diameter highlightedColor:(UIColor *)highlightedColor
{
    NSParameterAssert(image != nil);
    NSParameterAssert(diameter > 0);
    
    CGRect frame = CGRectMake(0.0f, 0.0f, diameter, diameter);
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        UIBezierPath *imgPath = [UIBezierPath bezierPathWithOvalInRect:frame];
        [imgPath addClip];
        [image drawInRect:frame];
        
        if (highlightedColor != nil) {
            CGContextSetFillColorWithColor(context, highlightedColor.CGColor);
            CGContextFillEllipseInRect(context, frame);
        }
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}



@end
