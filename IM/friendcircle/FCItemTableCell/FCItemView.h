//
//  FCItemView.h
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCItemViewModel.h"

@protocol FCItemViewDelegate;

@interface FCItemView : UIView

@property(nonatomic, strong) FCItemViewModel *model;
@property(weak) id<FCItemViewDelegate> delegate;

+ (CGFloat)heightForViewModel:(FCItemViewModel *)itemViewModel;


@end


@protocol FCItemViewDelegate <NSObject>

- (void)fcItemView:(FCItemView *)itemView commentsDidTapped:(FCICItemCellModel *)model;

- (void)fcItemViewCommentsRemark:(FCItemView *)itemView;

@end