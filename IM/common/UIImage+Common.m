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
    NSData *imageData = UIImageJPEGRepresentation(self, 0.9);
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

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
