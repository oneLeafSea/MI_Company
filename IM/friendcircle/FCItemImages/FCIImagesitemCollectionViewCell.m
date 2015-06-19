//
//  FCIImagesitemCollectionViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/6/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCIImagesitemCollectionViewCell.h"
#import <Masonry.h>
#import "UIImageView+common.h"

@interface FCIImagesitemCollectionViewCell()

@property(nonatomic, strong) UIImageView *imgView;

@end

@implementation FCIImagesitemCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fc_demo"]];
    [self.contentView addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setModel:(FCIImagesitemCollectionViewCellModel *)model {
    _model = model;
    [self.imgView rt_setImageWithURL:model.imgThumbUrl placeholderImage:[UIImage imageNamed:@"fc_demo"]];
}

@end
