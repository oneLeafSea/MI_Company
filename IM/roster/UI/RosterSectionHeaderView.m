//
//  RosterSectionHeaderView.m
//  IM
//
//  Created by 郭志伟 on 15-1-8.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RosterSectionHeaderView.h"
#import "LogLevel.h"

@interface RosterSectionHeaderView() {
    
    __weak IBOutlet UIButton *m_btn;
}
@end

@implementation RosterSectionHeaderView

- (void)awakeFromNib {
    UILongPressGestureRecognizer *longPress =  [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTap:)];
    longPress.minimumPressDuration = 1.0f;
    [m_btn addGestureRecognizer:longPress];
}


- (IBAction)taped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(RosterSectionHeaderViewTapped:tag:)]) {
        [self.delegate RosterSectionHeaderViewTapped:self tag:self.tag];
    }
}

- (void) longPressTap:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        DDLogInfo(@"Long pressed!");
        CGRect targetRectangle = self.frame;
        targetRectangle = [self convertRect:targetRectangle fromView:self.superview];
        [self becomeFirstResponder];
        [[UIMenuController sharedMenuController] setTargetRect:targetRectangle
                                                        inView:self];
        
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"分组管理"
                                                          action:@selector(grpMgrAction:)];
        
        [[UIMenuController sharedMenuController] setMenuItems:@[menuItem]];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}

- (void)grpMgrAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(RosterSectionHeaderViewGrpMgrTapped:tag:)]) {
        [self.delegate RosterSectionHeaderViewGrpMgrTapped:self tag:self.tag];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


@end
