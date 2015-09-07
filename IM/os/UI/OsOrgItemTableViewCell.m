//
//  OsOrgItemTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15-3-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "OsOrgItemTableViewCell.h"
#import "UIColor+Hexadecimal.h"

@implementation OsOrgItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImagView.layer.cornerRadius = 5;
    self.avatarImagView.layer.masksToBounds = YES;
    self.avatarImagView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewTapped:)];
    [self.avatarImagView addGestureRecognizer:tapGesture];
    self.addbtn.layer.masksToBounds = YES;
    self.addbtn.layer.cornerRadius = 5.0f;
    self.addbtn.layer.borderWidth = 1.0f;
    self.addbtn.layer.borderColor = [UIColor colorWithHex:@"#c8c7cc"].CGColor;
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

- (void)avatarImageViewTapped:(UIGestureRecognizer *)guesture {
    if ([self.delegate respondsToSelector:@selector(OsOrgItemTableViewCell:avatarDidSelectWithItem:)]) {
        [self.delegate OsOrgItemTableViewCell:self avatarDidSelectWithItem:self.item];
    }
}

@end
