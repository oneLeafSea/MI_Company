//
//  ChatMessageRecorderPanelView.m
//  testAudio
//
//  Created by 郭志伟 on 15-2-12.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageRecorderPanelView.h"
#import "ChatMessageVolumePanelView.h"

static const double kRecordBtnSz = 90.0f;

@interface ChatMessageRecorderPanelView() {
    ChatMessageVolumePanelView *m_volumePanel;
    UIButton                   *m_recordBtn;
    BOOL                       m_stop;
}

@end

@implementation ChatMessageRecorderPanelView


- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}


- (void)setup {
    self.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    m_volumePanel = [[ChatMessageVolumePanelView alloc] initWithFrame:CGRectZero];
    m_volumePanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:m_volumePanel];
    
    m_recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    m_recordBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [m_recordBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_record"] forState:UIControlStateNormal];
    [m_recordBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_record_press"] forState:UIControlStateHighlighted];
    [m_recordBtn addTarget:self action:@selector(recordBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:m_recordBtn];
    
    
    self.statusLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.statusLbl];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    // set up volumeView.
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
    
    NSLayoutConstraint *recordBtnCenterXConstraint = [NSLayoutConstraint constraintWithItem:m_recordBtn
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                 multiplier:1.0f
                                                                                   constant:0];
    [self addConstraint:recordBtnCenterXConstraint];
    
    
    // set status label
    NSLayoutConstraint *statusLblLeftConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:m_volumePanel
                                                                               attribute:NSLayoutAttributeLeft
                                                                              multiplier:1.0f
                                                                                constant:0];
    [self addConstraint:statusLblLeftConstraint];
    
    NSLayoutConstraint *statusLblTopConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:m_volumePanel
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0f
                                                                               constant:0];
    [self addConstraint:statusLblTopConstraint];
    
    NSLayoutConstraint *statusLblRightConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                              attribute:NSLayoutAttributeRight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:m_volumePanel
                                                                              attribute:NSLayoutAttributeRight
                                                                             multiplier:1.0f
                                                                               constant:0];
    [self addConstraint:statusLblRightConstraint];
    
    NSLayoutConstraint *statusLblBottomConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:m_volumePanel
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1.0f
                                                                                 constant:0];
    [self addConstraint:statusLblBottomConstraint];
    
    
    // set record btn.
    viewsDictionary = NSDictionaryOfVariableBindings(m_recordBtn, m_volumePanel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[m_volumePanel]-10-[m_recordBtn]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    NSLayoutConstraint *recordBtnHeightConstraint = [NSLayoutConstraint constraintWithItem:m_recordBtn
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0f
                                                                                  constant:kRecordBtnSz];
    [self addConstraint:recordBtnHeightConstraint];
    
    NSLayoutConstraint *recordBtnWidthConstaint = [NSLayoutConstraint constraintWithItem:m_recordBtn
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.0f
                                                                                constant:kRecordBtnSz];
    [self addConstraint:recordBtnWidthConstaint];
}


- (void)recordBtnPressed:(UIButton *)btn {
    NSLog(@"record btn pressed");
    m_stop = !m_stop;
    if (m_stop) {
        [m_recordBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_stop"] forState:UIControlStateNormal];
        [m_recordBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_stop_press"] forState:UIControlStateHighlighted];
        if ([self.delegate respondsToSelector:@selector(ChatMessageRecorderPanelViewStart:)]) {
            [self.delegate ChatMessageRecorderPanelViewStart:self];
        }
        
    } else {
        [m_recordBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_record"] forState:UIControlStateNormal];
        [m_recordBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_record_press"] forState:UIControlStateHighlighted];
        if ([self.delegate respondsToSelector:@selector(ChatMessageRecorderPanelViewStop:)]) {
            [self.delegate ChatMessageRecorderPanelViewStop:self];
        }
    }
    
}

- (void)setVolumeLevel:(CGFloat)level {
    m_volumePanel.ratio = level;
}

- (void)setVolumeStatusLblText:(NSString *)text {
    m_volumePanel.timeLbl.text = text;
}



@end
