//
//  RTMessagesCollectionViewDataSource.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RTMessagesCollectionView;
@protocol RTMessageData;
@protocol RTMessageBubbleImageDataSource;
@protocol RTMessageAvatarImageDataSource;

@protocol RTMessagesCollectionViewDataSource <UICollectionViewDataSource>

@required

- (NSString *)senderDisplayName;

- (NSString *)senderId;

- (id<RTMessageData>)collectionView:(RTMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath;

- (id<RTMessageBubbleImageDataSource>)collectionView:(RTMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath;

- (id<RTMessageAvatarImageDataSource>)collectionView:(RTMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSAttributedString *)collectionView:(RTMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath;

- (NSAttributedString *)collectionView:(RTMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath;

- (NSAttributedString *)collectionView:(RTMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath;

@end
