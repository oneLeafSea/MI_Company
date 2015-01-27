//
//  RecentRosterItemAddReqTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15-1-22.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RecentRosterItemAddReqTableViewCell.h"
#import "JSBadgeView.h"

@interface RecentRosterItemAddReqTableViewCell() {
    JSBadgeView *m_badgeView;
}
@end

@implementation RecentRosterItemAddReqTableViewCell

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
