//
//  RosterItermTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15-1-9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItermTableViewCell.h"

@implementation RosterItermTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImgView.layer.cornerRadius = 5;
    self.avatarImgView.layer.masksToBounds = YES;
    self.maskView.layer.cornerRadius = 5;
    self.maskView.layer.masksToBounds = YES;
    self.avatarImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewTapped:)];
    [self.avatarImgView addGestureRecognizer:tapGuesture];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)avatarImageViewTapped:(UITapGestureRecognizer *)guesture {
    if ([self.delegate respondsToSelector:@selector(RosterItermTableViewCell:AvatarDidSelectedWithItem:)]) {
        [self.delegate RosterItermTableViewCell:self AvatarDidSelectedWithItem:self.item];
    }
}

@end
