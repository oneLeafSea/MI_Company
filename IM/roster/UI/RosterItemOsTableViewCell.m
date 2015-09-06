//
//  RosterItemOsTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/9/1.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemOsTableViewCell.h"

@implementation RosterItemOsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImgView.layer.cornerRadius = 5;
    self.avatarImgView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
