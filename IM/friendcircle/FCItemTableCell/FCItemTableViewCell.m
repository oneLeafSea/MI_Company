//
//  FCItemTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/6/12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCItemTableViewCell.h"

#import <Masonry/Masonry.h>

#import "FCItemView.h"
#import "FCConstants.h"

@interface FCItemTableViewCell() <FCItemViewDelegate>

@property(nonatomic, strong) FCItemView *itemView;

@property(nonatomic, strong) UIView *spaceView;

@end

@implementation FCItemTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
                        model:(FCItemTableViewCellModel *)model
              reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.model = model;
        [self setup];
    }
    return self;
}

- (void)setModel:(FCItemTableViewCellModel *)model {
    _model = model;
    self.itemView.model = model.itemViewModel;
}

- (void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.itemView = [[FCItemView alloc] initWithFrame:CGRectZero];
     self.spaceView = [[UIView alloc] initWithFrame:CGRectZero];
    self.spaceView.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0];
    [self.contentView addSubview:self.spaceView];
    [self.contentView addSubview:self.itemView];
    self.itemView.delegate = self;
    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.spaceView.mas_top);
    }];
    
    
   [self.spaceView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.equalTo(self.contentView);
       make.bottom.equalTo(self.contentView);
       make.height.equalTo([NSNumber numberWithDouble:FC_SPACE_VIEW_HEIGHT]);
       make.right.equalTo(self.contentView);
   }];
    
}

- (void)setCurVC:(UIViewController *)curVC {
    _curVC = curVC;
    self.itemView.curVC = _curVC;
}

+ (CGFloat)heightForCellModel:(FCItemTableViewCellModel *)model {
    CGFloat itemViewHeight = [FCItemView heightForViewModel:model.itemViewModel];
    return itemViewHeight + FC_SPACE_VIEW_HEIGHT;
}

#pragma mark - FCItemViewDelegate
- (void)fcItemView:(FCItemView *)itemView commentsDidTapped:(FCICItemCellModel *)model {
    if ([self.delegate respondsToSelector:@selector(fcItemTableViewCell:commentsDidTapped:)]) {
        [self.delegate fcItemTableViewCell:self commentsDidTapped:model];
    }
}

- (void)fcItemViewCommentsRemark:(FCItemView *)itemView {
    if ([self.delegate respondsToSelector:@selector(fcItemTableViewCellCommentsRemark:)]) {
        [self.delegate fcItemTableViewCellCommentsRemark:self];
    }
}

@end
