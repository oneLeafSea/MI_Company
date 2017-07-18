//
//  RTMessagesLoadEarlierHeaderView.h
//  RTMessages
//
//  Created by 郭志伟 on 15/7/9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTMessagesLoadEarlierHeaderView;

FOUNDATION_EXPORT const CGFloat kRTMessagesLoadEarlierHeaderViewHeight;

@interface RTMessagesLoadEarlierHeaderView : UICollectionReusableView

+ (UINib *)nib;

+ (NSString *)headerReuseIdentifier;

@end
