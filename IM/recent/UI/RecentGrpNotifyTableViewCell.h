//
//  RecentGrpNotifyTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentGrpNotifyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;

@property (nonatomic) NSString *badgeText;

@end
