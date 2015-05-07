//
//  PopMenuItem.h
//  IM
//
//  Created by 郭志伟 on 15/5/4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kMenuTableViewWidth 150
#define kMenuTableViewSapcing 7

#define kMenuItemViewHeight 36
#define kMenuItemViewImageSapcing 15
#define kSeparatorLineImageViewHeight 0.5

@interface PopMenuItem : NSObject

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString *title;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;

@end
