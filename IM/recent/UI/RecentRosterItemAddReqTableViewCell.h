//
//  RecentRosterItemAddReqTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15-1-22.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentRosterItemAddReqTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@property (nonatomic) NSString *badgeText;
@end
