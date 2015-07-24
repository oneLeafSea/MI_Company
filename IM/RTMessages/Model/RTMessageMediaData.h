//
//  RTMessageMediaData.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RTMessageMediaData <NSObject>

@required

- (UIView *)mediaView;

- (CGSize)mediaViewDisplaySize;

- (UIView *)mediaPlaceholderView;

- (NSUInteger)mediaHash;

@end
