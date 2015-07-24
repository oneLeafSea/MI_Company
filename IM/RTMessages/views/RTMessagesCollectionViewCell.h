//
//  RTMessagesCollectionViewCell.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RTMessagesLabel.h"
#import "RTMessagesCellTextView.h"

@class RTMessagesCollectionViewCell;

@protocol RTMessagesCollectionViewCellDelegate <NSObject>

- (void)messagesCollectionViewCellDidTapAvatar:(RTMessagesCollectionViewCell *)cell;

- (void)messagesCollectionViewCellDidTapMessageBubble:(RTMessagesCollectionViewCell *)cell;

- (void)messagesCollectionViewCellDidTapCell:(RTMessagesCollectionViewCell *)cell atPosition:(CGPoint)position;

- (void)messagesCollectionViewCell:(RTMessagesCollectionViewCell *)cell didPerformAction:(SEL)action withSender:(id)sender;

@end

@interface RTMessagesCollectionViewCell : UICollectionViewCell

@property(weak, nonatomic) id<RTMessagesCollectionViewCellDelegate> delegate;
@property(weak, nonatomic, readonly) RTMessagesLabel *cellTopLabel;
@property(weak, nonatomic, readonly) RTMessagesLabel *messageBubbleTopLabel;
@property(weak, nonatomic, readonly) RTMessagesLabel *cellBottomLabel;
@property(weak, nonatomic, readonly) RTMessagesCellTextView *textView;
@property(weak, nonatomic, readonly) UIImageView *messageBubbleImageView;
@property(weak, nonatomic, readonly) UIView *messageBubbleContainerView;

@property(weak, nonatomic, readonly) UIImageView *avatarImageView;
@property(weak, nonatomic, readonly) UIView *avatarContainerView;
@property(weak, nonatomic) UIView *mediaView;
@property(weak, nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;


+ (UINib *)nib;

+ (NSString *)cellReuseIdentifier;

+ (NSString *)mediaCellReuseIdentifier;

+ (void)registerMenuAction:(SEL)action;


@end
