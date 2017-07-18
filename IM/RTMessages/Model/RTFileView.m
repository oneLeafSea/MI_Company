//
//  RTFileView.m
//  IM
//
//  Created by 郭志伟 on 15/7/17.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTFileView.h"
#import <Masonry.h>
#import "UIColor+RTMessages.h"

@interface RTFileView()

@property(nonatomic, strong) UIImageView *imgView;
@property(nonatomic, strong) UILabel     *fileNameLabel;
@property(nonatomic, strong) UILabel     *fileSzLabel;
@property(nonatomic, strong) UILabel     *statusLabel;
@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) UIButton    *downloadBtn;

@end

@implementation RTFileView

- (void)rt_configureView {
    [self addSubview:self.imgView];
    [self addSubview:self.fileNameLabel];
    [self addSubview:self.fileSzLabel];
    [self addSubview:self.statusLabel];
    [self addSubview:self.progressView];
    [self addSubview:self.downloadBtn];

    self.downloadBtn.hidden = self.isOutgoing;
    self.statusLabel.hidden = !self.isOutgoing;
    if (self.isOutgoing) {
        self.backgroundColor = [UIColor rt_messageBubbleLightGrayColor];
    } else {
        self.backgroundColor = [UIColor rt_messageBubbleGreenColor];
    }
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    [self addGestureRecognizer:longGesture];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self).offset(8);
        make.height.equalTo(self).offset(-16);
        make.width.equalTo(self.mas_height).offset(-16);
    }];
    [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgView.mas_right).offset(8);
        make.right.equalTo(self.mas_right).offset(8);
        make.top.equalTo(self).offset(8);
    }];
    
    [self.fileSzLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fileNameLabel);
        make.bottom.equalTo(self.imgView.mas_bottom);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.bottom.equalTo(self.imgView);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-4);
        make.left.equalTo(self.imgView);
        make.right.equalTo(self.statusLabel);
    }];
    
    
    [self.downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.fileSzLabel);
        make.right.equalTo(self).offset(-8);
    }];
}

- (instancetype) initWithFrame:(CGRect)frame
                    isOutgoing:(BOOL)isOutgoing {
    if (self = [super initWithFrame:frame]) {
        _isOutgoing = isOutgoing;
        [self rt_configureView];
    }
    return self;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fileBrowser_type_ppt"]];
        _imgView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imgView;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _fileNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _fileNameLabel.font = [UIFont systemFontOfSize:15];
    }
    return _fileNameLabel;
}

- (UILabel *)fileSzLabel {
    if (!_fileSzLabel) {
        _fileSzLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _fileSzLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _fileSzLabel.textColor = [UIColor lightGrayColor];
        _fileSzLabel.font = [UIFont systemFontOfSize:12];
    }
    return _fileSzLabel;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _statusLabel.textColor = [UIColor lightGrayColor];
        _statusLabel.font = [UIFont systemFontOfSize:12];
    }
    return _statusLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.progress = 1.0f;
    }
    return _progressView;
}

- (UIButton *)downloadBtn {
    if (!_downloadBtn) {
        _downloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _downloadBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        _downloadBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_downloadBtn sizeToFit];
        [_downloadBtn addTarget:self action:@selector(downloadBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadBtn;
}

#pragma mark -actions

- (void)downloadBtnTapped:(UIButton *)sender {
    
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



@end
