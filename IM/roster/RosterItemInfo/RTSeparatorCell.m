//
//  RTSeparatorCell.m
//  IM
//
//  Created by 郭志伟 on 15/7/3.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTSeparatorCell.h"

@implementation RTSeparatorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [[UIColor alloc] initWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 20);
}


@end
