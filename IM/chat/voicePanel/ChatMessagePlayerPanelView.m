//
//  ChatMessagePlayerPanelView.m
//  testAudio
//
//  Created by 郭志伟 on 15-2-11.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessagePlayerPanelView.h"
#import "ChatMessageVolumePanelView.h"
#import "CircleView.h"

static const double kPlayerBtnSz = 90.0f;
static const double kCancelBtnHeight = 40.0f;
static const double kSendBtnHeight = 40.0f;

#define kStyleColor [UIColor colorWithRed:75/255.0f green:192/255.0f blue:209/255.0f alpha:1.0f]


@interface ChatMessagePlayerPanelView() {
    
    ChatMessageVolumePanelView *m_volumePanel;
    UIButton                   *m_playerBtn;
    CircleView                 *m_circleView;
    UIButton                   *m_cancelBtn;
    UIButton                   *m_sendBtn;
    
}
@end

@implementation ChatMessagePlayerPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.stop = YES;
    self.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    m_volumePanel = [[ChatMessageVolumePanelView alloc] initWithFrame:CGRectZero];
    m_volumePanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:m_volumePanel];
    
    m_circleView = [[CircleView alloc] initWithFrame:CGRectMake(0, 0, kPlayerBtnSz + 3, kPlayerBtnSz + 3)];
    m_circleView.translatesAutoresizingMaskIntoConstraints = NO;
    m_circleView.strokeColor = kStyleColor;
//    [m_circleView setBackgroundColor:[UIColor blueColor]];
    [self addSubview:m_circleView];
    
    
    m_playerBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [m_playerBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_play"] forState:UIControlStateNormal];
    [m_playerBtn addTarget:self action:@selector(playerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    m_playerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:m_playerBtn];
    
    m_cancelBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [m_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [m_cancelBtn setTitleColor:kStyleColor forState:UIControlStateNormal];
    [m_cancelBtn addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    m_cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:m_cancelBtn];
    
    m_sendBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    m_sendBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [m_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [m_sendBtn setTitleColor:kStyleColor forState:UIControlStateNormal];
    [m_sendBtn addTarget:self action:@selector(sendBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:m_sendBtn];
    
    
    [self setupConstraints];
}

- (void)setVolumeLevel:(CGFloat)level {
    m_volumePanel.ratio = level;
}
- (void)setVolumeStatusLblText:(NSString *)text {
    m_volumePanel.timeLbl.text = text;
}

- (void)setStop:(BOOL)stop {
    _stop = stop;
    [m_playerBtn setBackgroundImage:self.stop ? [UIImage imageNamed:@"chatmsg_play"] : [UIImage imageNamed:@"chatmsg_stop"] forState:UIControlStateNormal];
    [m_circleView setStrokeEnd:0 animated:NO];
}


- (void)setupConstraints {
    // set volume view.
    NSLayoutConstraint *volumeViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:m_volumePanel
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                  multiplier:1.0f
                                                                                    constant:0];
    [self addConstraint:volumeViewCenterXConstraint];
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(m_volumePanel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[m_volumePanel]" options:0 metrics:nil views:viewsDictionary]];
    
    NSLayoutConstraint *volumeViewHeight = [NSLayoutConstraint constraintWithItem:m_volumePanel
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1 constant:30.0f];
    [self addConstraint:volumeViewHeight];
    
    NSLayoutConstraint *volumeViewWidth = [NSLayoutConstraint constraintWithItem:m_volumePanel
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:159.0f];
    [self addConstraint:volumeViewWidth];
    
    // set player btn.
    NSLayoutConstraint *playerBtnCenterXConstraint = [NSLayoutConstraint constraintWithItem:m_playerBtn
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                 multiplier:1.0f
                                                                                   constant:0];
    [self addConstraint:playerBtnCenterXConstraint];
    
    viewsDictionary = NSDictionaryOfVariableBindings(m_playerBtn, m_volumePanel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[m_volumePanel]-10-[m_playerBtn]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    NSLayoutConstraint *playerBtnHeightConstraint = [NSLayoutConstraint constraintWithItem:m_playerBtn
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0f
                                                                                   constant:kPlayerBtnSz];
    [self addConstraint:playerBtnHeightConstraint];
    
    NSLayoutConstraint *playerBtnWidthConstaint = [NSLayoutConstraint constraintWithItem:m_playerBtn
                                                                                attribute:NSLayoutAttributeWidth
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1.0f
                                                                                 constant:kPlayerBtnSz];
    [self addConstraint:playerBtnWidthConstaint];
    
    // set circle view.
    NSLayoutConstraint *circleViewTopViewConstrain = [NSLayoutConstraint constraintWithItem:m_circleView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:m_playerBtn
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:-1.0f];
    [self addConstraint:circleViewTopViewConstrain];
    
    NSLayoutConstraint *circleViewLeftConstrain = [NSLayoutConstraint constraintWithItem:m_circleView
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:m_playerBtn
                                                                             attribute:NSLayoutAttributeLeft
                                                                            multiplier:1.0f
                                                                              constant:-1.5];
    [self addConstraint:circleViewLeftConstrain];
    
    NSLayoutConstraint *circleViewRightConstraint = [NSLayoutConstraint constraintWithItem:m_circleView
                                                                                 attribute:NSLayoutAttributeRight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:m_playerBtn
                                                                                 attribute:NSLayoutAttributeRight
                                                                                multiplier:1.0
                                                                                  constant:0];
    [self addConstraint:circleViewRightConstraint];
    
    NSLayoutConstraint *circleViewBottomConstraint = [NSLayoutConstraint constraintWithItem:m_circleView
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:m_playerBtn
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:0];
    [self addConstraint:circleViewBottomConstraint];
    
    
    // set cancel btn.
    NSLayoutConstraint *cancelBtnLeftConstraint = [NSLayoutConstraint constraintWithItem:m_cancelBtn
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeLeft
                                                                              multiplier:1.0f
                                                                                constant:0];
    [self addConstraint:cancelBtnLeftConstraint];
    
    NSLayoutConstraint *cancelBtnRightConstraint = [NSLayoutConstraint constraintWithItem:m_cancelBtn
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterX
                                                                               multiplier:1.0f
                                                                                 constant:0];
    [self addConstraint:cancelBtnRightConstraint];
    
    NSLayoutConstraint *cancelBtnBottomConstraint = [NSLayoutConstraint constraintWithItem:m_cancelBtn
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:0];
    [self addConstraint:cancelBtnBottomConstraint];
    
    NSLayoutConstraint *cancelBtnHeightConstraint = [NSLayoutConstraint constraintWithItem:m_cancelBtn
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0f
                                                                                  constant:kCancelBtnHeight];
    [self addConstraint:cancelBtnHeightConstraint];
    
    
    // set send btn.
    NSLayoutConstraint *sendBtnLeftConstraint = [NSLayoutConstraint constraintWithItem:m_sendBtn
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeCenterX
                                                                              multiplier:1.0f
                                                                                constant:0];
    [self addConstraint:sendBtnLeftConstraint];
    
    NSLayoutConstraint *sendBtnRightConstraint = [NSLayoutConstraint constraintWithItem:m_sendBtn
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1.0f
                                                                                 constant:0];
    [self addConstraint:sendBtnRightConstraint];
    
    NSLayoutConstraint *sendBtnBottomConstraint = [NSLayoutConstraint constraintWithItem:m_sendBtn
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:0];
    [self addConstraint:sendBtnBottomConstraint];
    
    NSLayoutConstraint *sendBtnHeightConstraint = [NSLayoutConstraint constraintWithItem:m_sendBtn
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0f
                                                                                  constant:kSendBtnHeight];
    [self addConstraint:sendBtnHeightConstraint];

}


- (void)playerBtnPressed:(UIButton *)playerBtn {
    self.stop = !self.stop;
    if ([self.delegate respondsToSelector:@selector(ChatMessagePlayerPanelViewPlayerBtnPressed:stop:)]) {
        [self.delegate ChatMessagePlayerPanelViewPlayerBtnPressed:self stop:self.stop];
    }
    [self layoutIfNeeded];
}

- (void)cancelBtnPressed:(UIButton *)cancelBtn {
    if ([self.delegate respondsToSelector:@selector(ChatMessagePlayerPanelViewCancelBtnPressed:)]) {
        [self.delegate ChatMessagePlayerPanelViewCancelBtnPressed:self];
    }
}

- (void)sendBtnPressed:(UIButton *)sendBtn {
    if ([self.delegate respondsToSelector:@selector(ChatMessagePlayerPanelViewSendBtnPressed:)]) {
        [self.delegate ChatMessagePlayerPanelViewSendBtnPressed:self];
    }
}

- (void)setProgress:(double)progress {
    [m_circleView setStrokeEnd:progress animated:YES];
}

@end
