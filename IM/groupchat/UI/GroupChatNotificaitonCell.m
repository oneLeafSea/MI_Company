//
//  GroupChatNotificaitonCell.m
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatNotificaitonCell.h"
#import <Masonry.h>
#import "UIColor+Hexadecimal.h"
#import "UIColor+theme.h"

@interface GroupChatNotificaitonCell()


@end

@implementation GroupChatNotificaitonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configureCell];
    }
    return self;
}

- (void)configureCell {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.avatarImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"groupchat_private"]];
    [self.contentView addSubview:self.avatarImgView];
    self.grpNamelabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.grpNamelabel];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.textColor = [UIColor colorWithHex:@"#c9c9c9"];
    [self.contentView addSubview:self.contentLabel];
    
    self.acceptButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.acceptButton setTitle:@"同意" forState:UIControlStateNormal];
    self.acceptButton.layer.masksToBounds = YES;
    self.acceptButton.layer.cornerRadius = 5.0f;
    self.acceptButton.layer.borderWidth = 1.0f;
    self.acceptButton.tintColor = [UIColor themeColor];
    self.acceptButton.layer.borderColor = [UIColor colorWithHex:@"#c8c7cc"].CGColor;
    [self.contentView addSubview:self.acceptButton];
    [self.acceptButton addTarget:self action:@selector(acceptBtnDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.avatarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(8);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    [self.grpNamelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImgView.mas_right).offset(8);
        make.top.equalTo(self.avatarImgView);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImgView.mas_right).offset(8);
        make.bottom.equalTo(self.avatarImgView);
    }];
    
     [self.acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-8);
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@60);
        make.height.equalTo(@30);
    }];
}

- (void)acceptBtnDidTapped:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(GroupChatNotificaitonCellAcceptBtnDidTapped:)]) {
        [self.delegate GroupChatNotificaitonCellAcceptBtnDidTapped:self];
    }
}

@end
