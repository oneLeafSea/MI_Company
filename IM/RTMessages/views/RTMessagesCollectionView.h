//
//  RTMessagesCollectionView.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RTMessagesCollectionViewFlowLayout.h"
#import "RTMessagesCollectionViewDelegateFlowLayout.h"
#import "RTMessagesCollectionViewDataSource.h"
#import "RTMessagesCollectionViewCell.h"

@class RTMessagesTypingIndicatorFooterView;
@class RTMessagesLoadEarlierHeaderView;


@interface RTMessagesCollectionView : UICollectionView <RTMessagesCollectionViewCellDelegate>

@property (weak, nonatomic) id<RTMessagesCollectionViewDataSource> dataSource;
@property (weak, nonatomic) id<RTMessagesCollectionViewDelegateFlowLayout> delegate;
@property (strong, nonatomic) RTMessagesCollectionViewFlowLayout *collectionViewLayout;

@property (assign, nonatomic) BOOL typingIndicatorDisplaysOnLeft;

@property (strong, nonatomic) UIColor *typingIndicatorMessageBubbleColor;

@property (strong, nonatomic) UIColor *typingIndicatorEllipsisColor;

@property (strong, nonatomic) UIColor *loadEarlierMessagesHeaderTextColor;


- (RTMessagesTypingIndicatorFooterView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath;

- (RTMessagesLoadEarlierHeaderView *)dequeueLoadEarlierMessagesViewHeaderForIndexPath:(NSIndexPath *)indexPath;

@end
