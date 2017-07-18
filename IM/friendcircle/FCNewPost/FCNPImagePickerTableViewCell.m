//
//  FCNPImagePickerTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15/6/24.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCNPImagePickerTableViewCell.h"

#import <Masonry.h>
#import "FCNPImagePickerView.h"

@interface FCNPImagePickerTableViewCell() <FCNPImagePickerViewDelegate>

@property(nonatomic)FCNPImagePickerView *imgPickerView;

@end

@implementation FCNPImagePickerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.imgPickerView];
        [_imgPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.left.equalTo(self.contentView).offset(15);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.right.equalTo(self.contentView).offset(-15);
            
        }];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)setNaviController:(UINavigationController *)naviController {
    _naviController = naviController;
    self.imgPickerView.naviVC = _naviController;
}

- (FCNPImagePickerView *)imgPickerView {
    if (!_imgPickerView) {
        _imgPickerView = [[FCNPImagePickerView alloc] initWithFrame:self.contentView.frame];
        _imgPickerView.delegate = self;
    }
    return _imgPickerView;
}


- (void)FCNPImagePickerViewDataDidChanged:(FCNPImagePickerView *)pickerView height:(CGFloat)height {
    if ([self.delegate respondsToSelector:@selector(imagePickerTableViewCell:heightShouldChanged:)]) {
        [self.delegate imagePickerTableViewCell:self heightShouldChanged:height + 30.0f];
    }
}

- (NSArray *)imgArray {
    return self.imgPickerView.imgArray;
}

@end
