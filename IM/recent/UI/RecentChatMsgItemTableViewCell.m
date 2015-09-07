//
//  RecentMsgItemTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RecentChatMsgItemTableViewCell.h"
#import "JSBadgeView.h"

@interface RecentChatMsgItemTableViewCell() {
    JSBadgeView *m_badgeView;
    __weak IBOutlet UIView *badgeViewContainer;
}
@end

@implementation RecentChatMsgItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
    m_badgeView = [[JSBadgeView alloc] initWithParentView:badgeViewContainer alignment:JSBadgeViewAlignmentCenter];
    self.avatarImgView.layer.cornerRadius = 5.0;
    _avatarImgView.layer.masksToBounds = YES;
    self.avatarImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImgVieDidTapped:)];
    [self.avatarImgView addGestureRecognizer:tapGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBadgeText:(NSString *)badgeText {
    m_badgeView.badgeText = badgeText;
}

- (void)avatarImgVieDidTapped:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(RecentChatMsgItemTableViewCell:avatarImgViewDidTapped:)]) {
        [self.delegate RecentChatMsgItemTableViewCell:self avatarImgViewDidTapped:self.avatarImgView];
    }
}

@end
