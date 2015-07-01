//
//  FCNPTextTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/6/23.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCNPTextTableViewCell.h"
#import <Masonry.h>
#import "RTTextView.h"

@interface FCNPTextTableViewCell()<UITextViewDelegate>

@property(nonatomic, strong)RTTextView *textView;
@property(nonatomic, strong)UILabel    *countLbl;

@end

@implementation FCNPTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupTextView];
        [self setupCountLbl];
    }
    return self;
}

- (void)setupTextView {
    self.textView = [[RTTextView alloc] initWithFrame:self.contentView.frame];
    [self.contentView addSubview:self.textView];
    self.textView.placeholder = @"说点什么吧！";
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:16.0f];
    
    self.countLbl = [[UILabel alloc] initWithFrame:self.contentView.frame];
    [self.contentView addSubview:self.countLbl];
    self.countLbl.font = [UIFont systemFontOfSize:15.0f];
    self.countLbl.textColor = [UIColor lightGrayColor];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.left.equalTo(self.contentView).offset(5);
        make.right.equalTo(self.contentView).offset(-5);
        make.bottom.equalTo(self.countLbl.mas_top).offset(-5);
    }];
}

- (void)setupCountLbl {
    [self.countLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.right.equalTo(self.textView.mas_right);
    }];
}

- (void)setMaxCharacterCount:(NSUInteger)maxCharacterCount {
    _maxCharacterCount = maxCharacterCount;
    self.countLbl.text = [NSString stringWithFormat:@"%d/%d", self.textView.text.length, maxCharacterCount];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.countLbl.text = [NSString stringWithFormat:@"%d/%d", self.textView.text.length, self.maxCharacterCount];
}

- (NSString *)text {
    return self.textView.text;
}

- (RTTextView *)txtView {
    return self.textView;
}

@end
