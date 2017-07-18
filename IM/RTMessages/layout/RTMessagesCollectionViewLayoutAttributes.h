//
//  RTMessagesCollectionViewLayoutAttributes.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/7.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTMessagesCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes<NSCopying>

@property (strong, nonatomic) UIFont *messageBubbleFont;

@property (assign, nonatomic) CGFloat messageBubbleContainerViewWidth;

@property (assign, nonatomic) UIEdgeInsets textViewTextContainerInsets;

@property (assign, nonatomic) UIEdgeInsets textViewFrameInsets;

@property (assign, nonatomic) CGSize incomingAvatarViewSize;

@property (assign, nonatomic) CGSize outgoingAvatarViewSize;

@property (assign, nonatomic) CGFloat cellTopLabelHeight;

@property (assign, nonatomic) CGFloat messageBubbleTopLabelHeight;

@property (assign, nonatomic) CGFloat cellBottomLabelHeight;

@end
