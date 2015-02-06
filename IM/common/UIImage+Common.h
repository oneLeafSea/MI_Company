//
//  UIImage+Common.h
//  IM
//
//  Created by 郭志伟 on 15-2-5.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Common)

-(BOOL)saveToPath:(NSString*)path;

-(BOOL)saveToPath:(NSString *)path scale:(CGFloat)scale;

-(BOOL)saveToPath:(NSString *)path sz:(CGSize)sz;

@end
