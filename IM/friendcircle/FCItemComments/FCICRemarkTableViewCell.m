//
//  FCICRemarkTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/6/11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCICRemarkTableViewCell.h"
#import <Masonry.h>

@interface FCICRemarkTableViewCell()

@property(nonatomic, strong) UILabel *sayLbl;
//@property(nonatomic, strong) UIImageView *bgImgView;
@end

@implementation FCICRemarkTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.sayLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    self.sayLbl.textColor = [UIColor grayColor];
    self.sayLbl.text = @"我也说几句...";
    self.sayLbl.font = [UIFont systemFontOfSize:14];
    UIColor *color = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.0];
    self.contentView.backgroundColor = color;
    
    color = [UIColor colorWithRed:240/ 255.0f green:240/ 255.0f blue:240/ 255.0f alpha:1.0f];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:leftView];
    [self.contentView addSubview:self.sayLbl];
    leftView.backgroundColor = color;
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:topView];
    topView.backgroundColor = color;
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:rightView];
    rightView.backgroundColor = color;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:bottomView];
    bottomView.backgroundColor = color;
    
    
    [self.sayLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo([NSNumber numberWithDouble:10]);
    }];
    
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.width.equalTo([NSNumber numberWithDouble:1.0f]);
    }];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo([NSNumber numberWithDouble:1.0f]);
    }];
    
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.width.equalTo([NSNumber numberWithDouble:1.0f]);
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo([NSNumber numberWithDouble:1.0f]);
    }];
}

@end
