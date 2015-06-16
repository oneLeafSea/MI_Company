//
//  FCICItemCell.h
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCICItemCellModel.h"

@interface FCICItemCell : UITableViewCell

+ (CGFloat)defaultHeigh;

+ (CGFloat)cellHeighWithModel:(FCICItemCellModel *)model;

@property(strong, nonatomic) FCICItemCellModel *model;

@end
