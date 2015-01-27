//
//  RosterGrpMgrHeadView.m
//  IM
//
//  Created by 郭志伟 on 15-1-20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterGrpMgrHeadView.h"

@implementation RosterGrpMgrHeadView

- (IBAction)btnPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(RosterGrpMgrHeadViewTapped:)]) {
        [self.delegate RosterGrpMgrHeadViewTapped:self];
    }
}

@end
