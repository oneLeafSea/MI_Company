//
//  FCItemTableViewCell.h
//  IM
//
//  Created by 郭志伟 on 15/6/12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCItemTableViewCellModel.h"

@interface FCItemTableViewCell : UITableViewCell

@property(nonatomic, strong) FCItemTableViewCellModel *model;


+ (CGFloat)heightForCellModel:(FCItemTableViewCellModel *)model;

@end
