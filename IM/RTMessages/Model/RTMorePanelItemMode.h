//
//  RTMorePanelItemMode.h
//  IM
//
//  Created by 郭志伟 on 15/7/16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RTMorePanelItemMode : NSObject

- (instancetype) initWithTitle:(NSString *)title image:(UIImage *)image target:(id)target selector:(SEL)selector;

@property (nonatomic, assign, readonly) SEL selector;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) UIImage *image;

@property (weak, readonly) id target;

@end
