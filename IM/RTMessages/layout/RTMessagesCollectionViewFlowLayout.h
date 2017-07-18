//
//  RTMessagesCollectionViewFlowLayout.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTMessagesCollectionView;

FOUNDATION_EXPORT const CGFloat kRTMessagesCollectionViewCellLabelHeightDefault;
FOUNDATION_EXPORT const CGFloat kRTMessagesCollectionViewAvatarSizeDefault;

@interface RTMessagesCollectionViewFlowLayout : UICollectionViewFlowLayout

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (readonly, nonatomic) RTMessagesCollectionView *collectionView;
#pragma clang diagnostic pop

@property (assign, nonatomic) BOOL springinessEnabled;


@property (assign, nonatomic) NSUInteger springResistanceFactor;

@property (readonly, nonatomic) CGFloat itemWidth;

@property (readonly, nonatomic) UIFont *messageBubbleFont;

@property (assign, nonatomic) CGFloat messageBubbleLeftRightMargin;

@property (assign, nonatomic) UIEdgeInsets messageBubbleTextViewFrameInsets;

@property (assign, nonatomic) UIEdgeInsets messageBubbleTextViewTextContainerInsets;

@property (assign, nonatomic) CGSize incomingAvatarViewSize;

@property (assign, nonatomic) CGSize outgoingAvatarViewSize;

@property (assign, nonatomic) NSUInteger cacheLimit;

- (CGSize)messageBubbleSizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;



@end
