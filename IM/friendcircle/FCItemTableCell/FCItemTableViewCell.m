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

@interface FCItemTableViewCell()

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

- (void)setModel:(FCItemTableViewCellModel *)model {
    self.itemView.model = model.itemViewModel;
}

- (void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.itemView = [[FCItemView alloc] initWithFrame:CGRectZero];
     self.spaceView = [[UIView alloc] initWithFrame:CGRectZero];
    self.spaceView.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0];
    [self.contentView addSubview:self.spaceView];
    [self.contentView addSubview:self.itemView];
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

+ (CGFloat)heightForCellModel:(FCItemTableViewCellModel *)model {
    CGFloat itemViewHeight = [FCItemView heightForViewModel:model.itemViewModel];
    return itemViewHeight + FC_SPACE_VIEW_HEIGHT;
}

@end
