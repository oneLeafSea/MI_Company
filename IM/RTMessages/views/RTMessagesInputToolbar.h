//
//  RTQMessagesInputToolbar.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RTMessagesToolbarContentView.h"

@class RTMessagesInputToolbar;

@protocol RTMessagesInputToolbarDelegate <UIToolbarDelegate>

@required
- (void)messagesInputToolbar:(RTMessagesInputToolbar *)toolbar
      didPressRightBarButton:(UIButton *)sender;

- (void)messagesInputToolbar:(RTMessagesInputToolbar *)toolbar
       didPressLeftBarButton:(UIButton *)sender;

- (void)messagesInputToolbar:(RTMessagesInputToolbar *)toolbar
       didPressMidBarButton:(UIButton *)sender;

@end


@interface RTMessagesInputToolbar : UIToolbar

@property (weak, nonatomic) id<RTMessagesInputToolbarDelegate> delegate;

@property (weak, nonatomic, readonly) RTMessagesToolbarContentView *contentView;

@property (assign, nonatomic) BOOL sendButtonOnRight;

@property (assign, nonatomic) CGFloat preferredDefaultHeight;

@property (assign, nonatomic) NSUInteger maximumHeight;

//- (void)toggleSendButtonEnabled;

- (void)setLeftButtonImage:(UIImage *)image;
- (void)setMidButtonImage:(UIImage *)image;
- (void)setRightButtonImage:(UIImage *)imagee;

- (RTMessagesToolbarContentView *)loadToolbarContentView;

@end
