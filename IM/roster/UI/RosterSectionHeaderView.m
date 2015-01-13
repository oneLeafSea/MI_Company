//
//  RosterSectionHeaderView.m
//  IM
//
//  Created by 郭志伟 on 15-1-8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterSectionHeaderView.h"

@implementation RosterSectionHeaderView


- (IBAction)taped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(RosterSectionHeaderViewTapped:tag:)]) {
        [self.delegate RosterSectionHeaderViewTapped:self tag:self.tag];
    }
}

@end
