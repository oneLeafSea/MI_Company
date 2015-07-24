//
//  RTMessagesToolbarButtonFactory.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RTMessagesToolbarButtonFactory : NSObject

+ (UIButton *)defaultAccessoryButtonItem;

+ (UIButton *)defaultSendButtonItem;

+ (UIButton *)micButtonItem;

+ (UIButton *)emoteButtonItem;

+ (UIButton *)moreButtonItem;

@end
