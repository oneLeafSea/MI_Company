//
//  RosterItemGrpTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/9/1.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemGrpTableViewCell.h"

@implementation RosterItemGrpTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
