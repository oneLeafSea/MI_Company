//
//  RosterItemAddReqTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15-1-23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RosterItemAddReqTableViewCellDelegate;

@interface RosterItemAddReqTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *reqmsgLbl;
@property (weak, nonatomic) IBOutlet UILabel *acceptLbl;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;

@property (weak) id<RosterItemAddReqTableViewCellDelegate> delegate;

@end

@protocol RosterItemAddReqTableViewCellDelegate <NSObject>

- (void)RosterItemAddReqTableViewCellAcceptBtnTapped:(RosterItemAddReqTableViewCell *)cell;

@end
