//
//  FCItemCommentsView.h
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCItemCommentsViewModel.h"

@protocol FCItemCommentsViewDelegate;

@interface FCItemCommentsView : UIView

@property(nonatomic, strong) FCItemCommentsViewModel *model;
@property(weak) id<FCItemCommentsViewDelegate> delegate;

+ (CGFloat)heightForCommentsView:(FCItemCommentsViewModel *)model;

@end

@protocol FCItemCommentsViewDelegate <NSObject>

- (void)fcItemCommentsView:(FCItemCommentsView *)commentsView didSelectAt:(NSInteger)index;

- (void)fcItemCommentsViewRemarkCellTapped:(FCItemCommentsView *)commentsView cellModel:(FCItemCommentsViewModel *)commentsViewModel;

@end
