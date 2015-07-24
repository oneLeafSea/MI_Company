//
//  UIImage+RTMessages.m
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "UIImage+RTMessages.h"

#import "NSBundle+RTMessages.h"

@implementation UIImage (RTMessages)

- (UIImage *)rt_imageMaskedWithColor:(UIColor *)maskColor
{
    NSParameterAssert(maskColor != nil);
    
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -(imageRect.size.height));
        
        CGContextClipToMask(context, imageRect, self.CGImage);
        CGContextSetFillColorWithColor(context, maskColor.CGColor);
        CGContextFillRect(context, imageRect);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)rt_bubbleCompactImage {
    return [UIImage rt_bubbleImageFromBundleWithName:@"bubble_min"];
}


+ (UIImage *)rt_bubbleImageFromBundleWithName:(NSString *)name
{
    NSBundle *bundle = [NSBundle rt_messagesAssetBundle];
    NSString *path = [bundle pathForResource:name ofType:@"png" inDirectory:@"images"];
    return [UIImage imageWithContentsOfFile:path];
}

+ (UIImage *)rt_defaultTypingIndicatorImage {
    return [UIImage rt_bubbleImageFromBundleWithName:@"typing"];
}

+ (UIImage *)rt_defaultAccessoryImage {
    return [UIImage rt_bubbleImageFromBundleWithName:@"clip"];
}

+ (UIImage *)rt_micImage {
    return [UIImage rt_bubbleImageFromBundleWithName:@"yuyin"];
}

+ (UIImage *)rt_emoteImage {
    return [UIImage rt_bubbleImageFromBundleWithName:@"expression"];
}

+ (UIImage *)rt_moreImage {
    return [UIImage rt_bubbleImageFromBundleWithName:@"add"];
}

+ (UIImage *)rt_defaultPlayImage
{
    return [UIImage rt_bubbleImageFromBundleWithName:@"play"];
}

+ (UIImage *)rt_keyboardImage {
    return [UIImage rt_bubbleImageFromBundleWithName:@"keyboard"];
}


@end
