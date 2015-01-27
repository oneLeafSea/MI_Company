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
}
@end

@implementation RecentChatMsgItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
    m_badgeView = [[JSBadgeView alloc] initWithParentView:self.avatarImgView alignment:JSBadgeViewAlignmentTopRight];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBadgeText:(NSString *)badgeText {
    m_badgeView.badgeText = badgeText;
}

@end
