//
//  FCItemTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15/6/12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCItemTableViewCellModel.h"

@protocol FCItemTableViewCellDelegate;
@interface FCItemTableViewCell : UITableViewCell

@property(nonatomic, strong) FCItemTableViewCellModel *model;

@property(weak) id<FCItemTableViewCellDelegate> delegate;
+ (CGFloat)heightForCellModel:(FCItemTableViewCellModel *)model;

@end


@protocol FCItemTableViewCellDelegate <NSObject>

- (void)fcItemTableViewCell:(FCItemTableViewCell *)cell commentsDidTapped:(FCICItemCellModel *)model;
- (void)fcItemTableViewCellCommentsRemark:(FCItemTableViewCell *)cell;

@end