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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
