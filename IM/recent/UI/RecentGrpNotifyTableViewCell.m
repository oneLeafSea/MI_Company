//
//  RecentGrpNotifyTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RecentGrpNotifyTableViewCell.h"
#import "JSBadgeView.h"

@interface RecentGrpNotifyTableViewCell() {
    JSBadgeView *m_badgeView;
}
@property (weak, nonatomic) IBOutlet UIView *badgeContainerView;

@end

@implementation RecentGrpNotifyTableViewCell

- (void)awakeFromNib {
    m_badgeView = [[JSBadgeView alloc] initWithParentView:self.badgeContainerView alignment:JSBadgeViewAlignmentCenter];
    self.avatarImgView.layer.cornerRadius = 5.0;
    _avatarImgView.layer.masksToBounds = YES;
    self.avatarImgView.userInteractionEnabled = YES;
}

- (void)setBadgeText:(NSString *)badgeText {
    m_badgeView.badgeText = badgeText;
}

@end
