//
//  RTMessagesCollectionViewDelegateFlowLayout.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RTMessagesCollectionView;
@class RTMessagesCollectionViewFlowLayout;
@class RTMessagesCollectionViewCell;
@class RTMessagesLoadEarlierHeaderView;

@protocol RTMessagesCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional
- (CGFloat)collectionView:(RTMessagesCollectionView *)collectionView
                   layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)collectionView:(RTMessagesCollectionView *)collectionView
                   layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)collectionView:(RTMessagesCollectionView *)collectionView
                   layout:(RTMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(RTMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(RTMessagesCollectionView *)collectionView didLongPressedAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath;


- (void)collectionView:(RTMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(RTMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation;

//- (void)collectionView:(RTMessagesCollectionView *)collectionView
//                header:(RTMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender;

- (void)collectionViewDidTapped:(RTMessagesCollectionView *)collectionView;

@end
