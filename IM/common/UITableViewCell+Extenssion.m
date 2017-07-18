//
//  UITableViewCell+Extenssion.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "UITableViewCell+Extenssion.h"

@implementation UITableViewCell (Extenssion)

+ (UITableViewCell *)separatorCell {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.contentView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1.0];
    cell.separatorInset = UIEdgeInsetsMake(0.0, [UIScreen mainScreen].bounds.size.width, 0.0, 0.0);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
