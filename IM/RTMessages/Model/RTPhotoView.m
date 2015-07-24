//
//  RTPhotoView.m
//  IM
//
//  Created by 郭志伟 on 15/7/20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTPhotoView.h"
#import <Masonry/Masonry.h>
#import "UIImageView+common.h"

@interface RTPhotoView()

@property(nonatomic, strong)UIImageView *imgView;

@end

@implementation RTPhotoView

#pragma mark - init
- (void)rt_configureView {
    [self addSubview:self.imgView];
    [self setupConstraints];
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    [self addGestureRecognizer:longGesture];
}

- (void)setupConstraints {
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self rt_configureView];
    }
    return self;
}

- (void)awakeFromNib {
    [self rt_configureView];
}

- (void)longGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menuControler = [UIMenuController sharedMenuController];
        CGRect targetRectangle = gesture.view.frame;
        targetRectangle = [gesture.view convertRect:targetRectangle fromView:gesture.view.superview];
        [menuControler setTargetRect:targetRectangle inView:self];
        [menuControler setMenuVisible:YES animated:YES];
    }
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma mark - getters

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imgView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imgView;
}

#pragma mark - setters
- (void)setImgUrl:(NSURL *)imgUrl {
    _imgUrl = [imgUrl copy];
    [self.imgView rt_setImageWithURL:_imgUrl placeholderImage:[UIImage imageNamed:@"fc_demo"]];
}

@end
