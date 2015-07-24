//
//  RTMessagesComposerTextView.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTMessagesComposerTextView : UITextView

@property (copy, nonatomic) NSString *placeHolder;

@property (strong, nonatomic) UIColor *placeHolderTextColor;

- (BOOL)hasText;

@end
