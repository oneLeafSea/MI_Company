//
//  UIImage+Common.m
//  IM
//
//  Created by 郭志伟 on 15-2-5.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "UIImage+Common.h"

@implementation UIImage (Common)

-(BOOL)saveToPath:(NSString*)path {
    NSData *imageData = UIImageJPEGRepresentation(self, 0.1);
    return [imageData writeToFile:path atomically:YES];
}

-(BOOL)saveToPath:(NSString *)path scale:(CGFloat)scale {
    UIImage *img = [self compressForUpload:self :scale];
    return [img saveToPath:path];
}

- (UIImage *)compressForUpload:(UIImage *)original :(CGFloat)scale
{
    // Calculate new size given scale factor.
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}

- (UIImage *)compressForUpload:(UIImage *)original sz:(CGSize)sz
{
    UIGraphicsBeginImageContext(sz);
    [original drawInRect:CGRectMake(0, 0, sz.width, sz.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}

-(BOOL)saveToPath:(NSString *)path sz:(CGSize)sz {
    UIImage *img = [self compressForUpload:self sz:sz];
    return [img saveToPath:path];
}

- (UIImage *)scaleToSize:(CGSize)sz {
    return [self compressForUpload:self sz:sz];
}




@end
