//
//  RTAudioView.m
//  IM
//
//  Created by 郭志伟 on 15/7/20.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTAudioView.h"
#import "UIColor+RTMessages.h"
#import <Masonry/Masonry.h>
#import "UIColor+Hexadecimal.h"

@interface RTAudioView()

@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UIImageView *imgView;
@property(nonatomic, assign) BOOL  isOutgoing;

@end

@implementation RTAudioView

#pragma mark - init
- (void)rt_configureView {
    [self addSubview:self.timeLabel];
    [self addSubview:self.imgView];
    [self setupConstraints];
    
    if (self.isOutgoing) {
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = [UIColor colorWithHex:@"#b2e866"];
    }
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    [self addGestureRecognizer:longGesture];
}

- (void)setupConstraints {
    if (self.isOutgoing) {
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.centerY.equalTo(self);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.imgView.mas_left).offset(-3);
            make.centerY.equalTo(self);
        }];
    } else {
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.centerY.equalTo(self);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).offset(3);
            make.centerY.equalTo(self);
        }];
    }
}

- (void)setTime:(NSString *)time {
    self.timeLabel.text = [NSString stringWithFormat:@"%@'", time];
}

- (instancetype)initWithFrame:(CGRect)frame
                   isOutgoing:(BOOL)isOutgoing {
    if (self = [super initWithFrame:frame]) {
        self.isOutgoing = isOutgoing;
        [self rt_configureView];
    }
    return self;
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

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.text = @"2'";
        if (!self.isOutgoing) {
            _timeLabel.textColor = [UIColor whiteColor];
        }
    }
    return _timeLabel;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        if (self.isOutgoing) {
            _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_esl"]];
            _imgView.animationImages = @[[UIImage imageNamed:@"chatmsg_esj"], [UIImage imageNamed:@"chatmsg_esk"],[UIImage imageNamed:@"chatmsg_esl"]];
        } else {
            _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_esi"]];
            _imgView.animationImages = @[[UIImage imageNamed:@"chatmsg_esg"], [UIImage imageNamed:@"chatmsg_esh"],[UIImage imageNamed:@"chatmsg_esi"]];
        }
        _imgView.translatesAutoresizingMaskIntoConstraints = NO;
        _imgView.animationDuration = 0.9f;
    }
    return _imgView;
}

#pragma mark - setters
- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    if (playing) {
        [self.imgView startAnimating];
    } else {
        [self.imgView stopAnimating];
    }
}

@end
