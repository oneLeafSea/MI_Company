//
//  GroupChatNotificaitonCell.h
//  IM
//
//  Created by 郭志伟 on 15/9/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatNotificaitonCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImgView;
@property (nonatomic, strong) UILabel     *grpNamelabel;
@property (nonatomic, strong) UILabel     *contentLabel;
@property (nonatomic, strong) UIButton    *acceptButton;

@end
