//
//  OsOrgItemTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15-3-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "OsOrgItemTableViewCell.h"

@implementation OsOrgItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImagView.layer.cornerRadius = 5;
    self.avatarImagView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addBtnPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(OsOrgItemTableViewCell:orgItem:)]) {
        [self.delegate OsOrgItemTableViewCell:self orgItem:self.item];
    }
}

@end
