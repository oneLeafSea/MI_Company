//
//  FCICItemCell.m
//  IM
//
//  Created by 郭志伟 on 15/6/10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Masonry.h>
#import "FCICItemCell.h"
#import "FCConstants.h"
#import "FCICItemContentView.h"

#define FCICITEMCELL_MARGIN 6.0f
#define FCICITEMCELL_FONT_SIZE 13

@interface FCICItemCell()

@property(nonatomic, strong) UILabel *nameLbl;
@property(nonatomic, strong) UILabel *repliedNameLbl;
@property(nonatomic, strong) UILabel *replyLbl;
@property(nonatomic, strong) FCICItemContentView *contentLbl;

@property (nonatomic) CGFloat margin;

@end

@implementation FCICItemCell


+ (CGFloat)defaultHeigh {
    return 16.0f;
}

+ (CGFloat)cellHeighWithModel:(FCICItemCellModel *)model {
    return [FCICItemCell contentSz:model].height + 2 * FCICITEMCELL_MARGIN;
}

+ (CGSize)contentSz:(FCICItemCellModel *)model {
    CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width - FC_COMMENTS_LEFT_OFFSET - FC_COMMENTS_RIGHT_OFFSET;
    
    CGSize nameLblSz = [FCICItemCell sizeForText:model.name];
    CGSize replyLblSz = model.replied ? [FCICItemCell sizeForText:@"回复"] : CGSizeZero;
    CGSize repliedNameLblSz = model.replied ? [FCICItemCell sizeForText:model.repliedName] : CGSizeZero;
    
    
    CGFloat contentLblWidth = cellWidth - FCICITEMCELL_MARGIN * 2 - nameLblSz.width - replyLblSz.width - repliedNameLblSz.width;
    CGSize contentSz = [model.content boundingRectWithSize:CGSizeMake(contentLblWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FCICITEMCELL_FONT_SIZE]}  context:nil].size;
    return CGSizeMake(contentLblWidth, contentSz.height);
}

+ (CGSize)sizeForText:(NSString *)txt {
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:FCICITEMCELL_FONT_SIZE]};
    CGSize textSize = [txt sizeWithAttributes:attributes];
    return textSize;
}


- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if ([self setup] == NO) {
            return nil;
        }
    }
    return self;
}

- (BOOL)setup {
    self.nameLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLbl.font = [UIFont systemFontOfSize:FCICITEMCELL_FONT_SIZE];
    self.nameLbl.textColor = [UIColor colorWithRed:41/255.0f green:89/255.0f blue:152/255.0f alpha:1.0];
    self.repliedNameLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    self.repliedNameLbl.font = [UIFont systemFontOfSize:FCICITEMCELL_FONT_SIZE];
    self.repliedNameLbl.textColor = [UIColor colorWithRed:41/255.0f green:89/255.0f blue:152/255.0f alpha:1.0];
    self.replyLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    self.replyLbl.text = @"回复";
    self.replyLbl.font = [UIFont systemFontOfSize:FCICITEMCELL_FONT_SIZE];

    self.contentLbl = [[FCICItemContentView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.nameLbl];
    [self.contentView addSubview:self.repliedNameLbl];
    [self.contentView addSubview:self.replyLbl];
    [self.contentView addSubview:self.contentLbl];
    self.margin = FCICITEMCELL_MARGIN;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.contentView addGestureRecognizer:longPressGesture];
    return YES;
}

- (void)setModel:(FCICItemCellModel *)model {
    _model = model;
    self.nameLbl.text = model.name;
    self.repliedNameLbl.text = model.repliedName;
    self.contentLbl.text = model.content;
    [self setupConstraints];
    [self layoutIfNeeded];
}


- (void)setupConstraints {
    [self.nameLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(self.margin);
    }];
    if (self.model.replied) {
       [self.replyLbl mas_updateConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(self.nameLbl.mas_right);
           make.top.equalTo(self.nameLbl);
       }];
        self.replyLbl.hidden = NO;
        [self.repliedNameLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.replyLbl.mas_right);
            make.top.equalTo(self.replyLbl);
        }];
       [self.contentLbl mas_updateConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.contentView).offset(self.margin);
           make.left.equalTo(self.repliedNameLbl.mas_right);
           CGSize sz = [FCICItemCell contentSz:self.model];
           CGFloat height = sz.height + 6; // 不知道为什么要加上6个像素后去能画出来。
           make.height.equalTo([NSNumber numberWithDouble:height]);
           CGFloat width = sz.width;
           make.width.equalTo([NSNumber numberWithDouble:width]);
       }];
    } else {
        [self.replyLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLbl.mas_right);
            make.top.equalTo(self.nameLbl);
            make.height.equalTo([NSNumber numberWithDouble:0]);
            make.width.equalTo([NSNumber numberWithDouble:0]);
        }];
        self.replyLbl.hidden = YES;
        [self.repliedNameLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.replyLbl.mas_right);
            make.bottom.equalTo(self.replyLbl);
            make.width.equalTo([NSNumber numberWithDouble:0]);
            make.height.equalTo([NSNumber numberWithDouble:0]);
        }];
        [self.contentLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(self.margin);
            make.left.equalTo(self.repliedNameLbl.mas_right);
            CGSize sz = [FCICItemCell contentSz:self.model];
            CGFloat height = sz.height + 6; // 不知道为什么要加上6个像素后去能画出来。
            make.height.equalTo([NSNumber numberWithDouble:height]);
            CGFloat width = sz.width;
            make.width.equalTo([NSNumber numberWithDouble:width]);
        }];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan){
        NSLog(@"UIGestureRecognizerStateBegan.");
        
    }

}

@end
