//
//  RosterGrpMgrTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15-1-20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterGrpMgrTableViewCell.h"

@interface RosterGrpMgrTableViewCell()
@end

@implementation RosterGrpMgrTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.grpNameTextField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [self.grpNameTextField addTarget:self action:@selector(textFieldDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)textFieldDidChange:(UITextField *)theTextField {
    if ([self.delegate respondsToSelector:@selector(RosterGrpMgrTableViewCellTextFieldChanged:tag:)]) {
        [self.delegate RosterGrpMgrTableViewCellTextFieldChanged:self tag:self.tag];
    }
}

- (void)textFieldDidEnd:(UITextField *)theTextField {
    if ([self.delegate respondsToSelector:@selector(RosterGrpMgrTableViewCellTextFieldDidEnd:tag:)]) {
        [self.delegate RosterGrpMgrTableViewCellTextFieldDidEnd:self tag:self.tag];
    }
}

@end
