//
//  RTTextView.h
//  IM
//
//  Created by 郭志伟 on 15/6/15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const RTTextViewContentSizeDidChangeNotification;

@interface RTTextView : UITextView

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) UIColor  *placeholderColor;

@property (nonatomic, readwrite) NSUInteger maxNumberOfLines;
@property (nonatomic, readonly) NSUInteger numberOfLines;
@property (nonatomic, readonly) BOOL isExpanding;

@end
