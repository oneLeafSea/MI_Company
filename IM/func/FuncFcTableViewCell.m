//
//  FuncFcTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/7/2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FuncFcTableViewCell.h"
#import <Masonry/Masonry.h>


@interface FuncFcTableViewCell()

@property(nonatomic, strong) UIImageView *badgeView;

@end

@implementation FuncFcTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.badgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"func_fc_badge"]];
        [self.contentView addSubview:self.badgeView];
        [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(5);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setBadgeShow:(BOOL)badgeShow {
    _badgeShow = badgeShow;
    self.badgeView.hidden = !_badgeShow;
}



@end
