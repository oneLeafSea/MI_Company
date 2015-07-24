//
//  RTMessagesTypingIndicatorFooterView.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT const CGFloat kRTMessagesTypingIndicatorFooterViewHeight;

@interface RTMessagesTypingIndicatorFooterView : UICollectionReusableView

+ (UINib *)nib;

+ (NSString *)footerReuseIdentifier;

#pragma mark - Typing indicator

- (void)configureWithEllipsisColor:(UIColor *)ellipsisColor
                messageBubbleColor:(UIColor *)messageBubbleColor
               shouldDisplayOnLeft:(BOOL)shouldDisplayOnLeft
                 forCollectionView:(UICollectionView *)collectionView;

@end
