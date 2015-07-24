//
//  RTMoreViewCollectionViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/7/15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMoreViewCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface RTMoreViewCollectionViewCell()

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UILabel     *textLabel;

@end

@implementation RTMoreViewCollectionViewCell

- (void)rt_configureCell {
    [self addSubview:self.imageView];
    [self addSubview:self.textLabel];
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(7);
        make.right.equalTo(self).offset(-7);
        make.top.equalTo(self).offset(7);
        make.bottom.equalTo(self.textLabel.mas_top).offset(-7);
    }];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView);
        make.right.equalTo(self.imageView);
        make.bottom.equalTo(self).offset(-7);
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self rt_configureCell];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addSubview:self.imageView];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_default"]];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textLabel;
}


@end
