//
//  AvatarContainerCellCollectionViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/5/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "AvatarContainerCellCollectionViewCell.h"

@implementation AvatarContainerCellCollectionViewCell

+ (instancetype)instanceFromNib {
    return [[[NSBundle mainBundle]loadNibNamed:@"AvatarContainerCellCollectionViewCell" owner:nil options:nil]lastObject];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [AvatarContainerCellCollectionViewCell instanceFromNib];
}

@end
