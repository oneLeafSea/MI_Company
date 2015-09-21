//
//  RosterItermTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15-1-9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RosterItem.h"

@protocol RosterItermTableViewCellDelegate;

@interface RosterItermTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;

@property (weak, nonatomic) IBOutlet UIView *maskView;

@property(weak, nonatomic) RosterItem *item;
@property(weak) id<RosterItermTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UIImageView *device1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *device2ImageView;

@end

@protocol RosterItermTableViewCellDelegate <NSObject>

- (void)RosterItermTableViewCell:(RosterItermTableViewCell *)cell AvatarDidSelectedWithItem:(RosterItem *)item;

@end