//
//  GroupChatListTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15-3-3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatListTableViewCell.h"

@implementation GroupChatListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.logoImgView.layer.cornerRadius = 5;
    self.logoImgView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
