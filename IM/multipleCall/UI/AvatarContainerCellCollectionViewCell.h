//
//  AvatarContainerCellCollectionViewCell.h
//  IM
//
//  Created by 郭志伟 on 15/5/6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvatarContainerCellCollectionViewCell : UICollectionViewCell

+ (instancetype)instanceFromNib;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UIImageView *speakerImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;

@end
