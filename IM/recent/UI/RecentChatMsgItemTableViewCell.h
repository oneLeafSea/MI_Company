//
//  RecentMsgItemTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15-1-21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecentChatMsgItemTableViewCellDelegate;

@interface RecentChatMsgItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;

@property (weak, nonatomic) IBOutlet UILabel *lastMsgLbl;

@property (nonatomic) NSString *badgeText;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;

@property (weak) id<RecentChatMsgItemTableViewCellDelegate> delegate;

@end

@protocol RecentChatMsgItemTableViewCellDelegate <NSObject>

- (void)RecentChatMsgItemTableViewCell:(RecentChatMsgItemTableViewCell *)cell avatarImgViewDidTapped:(UIImageView *)avatarImgView;

@end