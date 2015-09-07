//
//  OsOrgItemTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15-3-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OsItem.h"

@protocol OsOrgItemTableViewCellDelegate;

@interface OsOrgItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImagView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (nonatomic) OsItem *item;
@property(weak) id<OsOrgItemTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *addbtn;

@end

@protocol OsOrgItemTableViewCellDelegate <NSObject>

- (void)OsOrgItemTableViewCell:(OsOrgItemTableViewCell *)cell orgItem:(OsItem *)item;

- (void)OsOrgItemTableViewCell:(OsOrgItemTableViewCell *)cell avatarDidSelectWithItem:(OsItem *)item;

@end