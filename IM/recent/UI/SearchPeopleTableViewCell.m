//
//  SearchPeopleTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/9/1.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "SearchPeopleTableViewCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+Hexadecimal.h"

@implementation SearchPeopleTableViewCell

- (void)awakeFromNib {
    [self configCell];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configCell];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

- (void)configCell {
    [self.contentView addSubview:self.avatarImgView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
    self.detailLabel.font = [UIFont systemFontOfSize:14];
    self.detailLabel.textColor = [UIColor colorWithHex:@"#6D797A"];
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.avatarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(8);
        make.width.equalTo([NSNumber numberWithDouble:44]);
        make.height.equalTo([NSNumber numberWithDouble:44]);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImgView.mas_right).offset(8);
        make.top.equalTo(self.avatarImgView.mas_top);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImgView.mas_right).offset(8);
        make.bottom.equalTo(self.avatarImgView.mas_bottom);
    }];
}

- (UIImageView *)avatarImgView {
    if (_avatarImgView == nil) {
        _avatarImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_default"]];
        _avatarImgView.layer.cornerRadius = 5;
        _avatarImgView.layer.masksToBounds = YES;
    }
    return _avatarImgView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _nameLabel;
}

- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _detailLabel;
}

@end
