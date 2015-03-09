//
//  GroupChatItemListTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15-3-3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatItemListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *rankLbl;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;

@end
