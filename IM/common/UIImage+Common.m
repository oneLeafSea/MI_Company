//
//  UIImage+Common.m
//  IM
//
//  Created by 郭志伟 on 15-2-5.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "UIImage+Common.h"
#import <AssetsLibrary/ALAsset.h>
#import <ImageIO/ImageIO.h>

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
//    UIImage *img = [self compressForUpload:self sz:sz];
//    UIImage *img = [self resizeImageToMaxSize:sz.width];
    UIImage *img = [UIImage imageWithImage:self scaledToFillSize:sz];
    return [img saveToPath:path];
}

- (UIImage *)scaleToSize:(CGSize)sz {
    return [self compressForUpload:self sz:sz];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (UIImage *)thumbnail {
//    ALAsset *asset;
//    
//    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
//    
//    NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:
//                                      (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
//                                      (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
//                                      (id)[NSNumber numberWithFloat:100], kCGImageSourceThumbnailMaxPixelSize,
//                                      nil];
//    
//    CGImageRef generatedThumbnail = [assetRepresentation CGImageWithOptions:thumbnailOptions];
//    
//    UIImage *thumbnailImage = [UIImage imageWithCGImage:generatedThumbnail];
    return nil;
}

-(UIImage*)resizeImageToMaxSize:(CGFloat)max filePath:(NSString *)path
{
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], NULL);
    if (!imageSource)
        return nil;
    
    CFDictionaryRef options = (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
                                                (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageIfAbsent,
                                                (id)[NSNumber numberWithFloat:max], (id)kCGImageSourceThumbnailMaxPixelSize,
                                                nil];
    CGImageRef imgRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
    
    UIImage* scaled = [UIImage imageWithCGImage:imgRef];
    
    CGImageRelease(imgRef);
    CFRelease(imageSource);
    
    return scaled;
}

- (UIImage *)resizeImageToMaxSize:(CGFloat)max {
    CGImageSourceRef imageSource = (__bridge CGImageSourceRef)(self);
    if (!imageSource)
        return nil;
    
    CFDictionaryRef options = (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                         (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
                                                         (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageIfAbsent,
                                                         (id)[NSNumber numberWithFloat:max], (id)kCGImageSourceThumbnailMaxPixelSize,
                                                         nil];
    CGImageRef imgRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
    
    UIImage* scaled = [UIImage imageWithCGImage:imgRef];
    
    CGImageRelease(imgRef);
    CFRelease(imageSource);
    
    return scaled;
}



@end
