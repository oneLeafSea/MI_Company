//
//  FCNPImagePickerCollectionViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/6/23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCNPImagePickerCollectionViewCell.h"

#import <Masonry.h>

@implementation FCNPImagePickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupImgView];
    }
    return self;
}

- (void)setupImgView {
    _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fc_imgpicker_add"]];
    [self.contentView addSubview:_imgView];
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

@end
