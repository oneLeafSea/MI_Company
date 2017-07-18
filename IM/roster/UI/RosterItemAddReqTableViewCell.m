//
//  RosterItemAddReqTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15-1-23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterItemAddReqTableViewCell.h"

@implementation RosterItemAddReqTableViewCell

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)accept:(id)sender {
    if ([self.delegate respondsToSelector:@selector(RosterItemAddReqTableViewCellAcceptBtnTapped:)]) {
        [self.delegate RosterItemAddReqTableViewCellAcceptBtnTapped:self];
    }
}

@end
