//
//  RTMicPanelView.m
//  IM
//
//  Created by 郭志伟 on 15/7/14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMicPanelView.h"

#import "RTScaleableRoundView.h"
#import "RTMicButton.h"
#import "ChatMessageVolumePanelView.h"
#import "CircleView.h"
#import "AudioRecorder.h"
#import "AudioPlayer.h"
#import "NSUUID+StringUUID.h"

static const double kPlayerViewSz = 40.0f;
static const double kPlayerViewMaxSz = 60.0f;
static const double kTrashCanViewSz = 40.0f;
static const double kTrashCanViewMaxSz = 60.0f;
static const double kSpeakerBtnSz = 90.0f;

static const double kCancelBtnHeight = 40.0f;
static const double kSendBtnHeight = 40.0f;

static const double kPlayerBtnSz = 90.0f;

#define kStyleColor [UIColor colorWithRed:75/255.0f green:192/255.0f blue:209/255.0f alpha:1.0f]

@interface RTMicPanelView() <RTMicButtonDelegate, AudioRecorderDelegate, AudioPlayerDelegate> {
    RTMicButton               *m_speakerBtn;
    RTScaleableRoundView          *m_playerView;
    RTScaleableRoundView          *m_trashCanView;
    ChatMessageVolumePanelView  *m_voluemView;
    UIImageView                 *m_directionImgView;
    NSLayoutConstraint          *m_playerViewWidthConstaint;
    NSLayoutConstraint          *m_playerViewHeightConstaint;
    NSLayoutConstraint          *m_trashCanWidthConstaint;
    NSLayoutConstraint          *m_trashCanHeightConstaint;
    
    UIButton                   *m_playerBtn;
    CircleView                 *m_circleView;
    UIButton                   *m_cancelBtn;
    UIButton                   *m_sendBtn;
    
}
@property(nonatomic) BOOL stop;
@property(nonatomic) double progress;

@property(weak) AudioRecorder *recorder;
@property(weak) AudioPlayer *player;

@property(nonatomic, copy)NSString *audioPath;
@property(assign, nonatomic) CGFloat duration;

@end

@implementation RTMicPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    
}

- (void) awakeFromNib {
    [self setup];
}


- (void)setup {
    self.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    
    self.recorder = [AudioRecorder shareRecorder];
    self.player = [AudioPlayer sharePlayer];
    _stop = YES;
    
    m_directionImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_move_direction"]];
    m_directionImgView.translatesAutoresizingMaskIntoConstraints = NO;
    m_directionImgView.hidden = YES;
    [self addSubview:m_directionImgView];
    
    m_speakerBtn = [[RTMicButton alloc] initWithFrame:CGRectZero];
    m_speakerBtn.delegate = self;
    m_speakerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:m_speakerBtn];
    
    m_playerView = [[RTScaleableRoundView alloc] initWithFrame:CGRectZero];
    m_playerView.translatesAutoresizingMaskIntoConstraints = NO;
    m_playerView.hidden = YES;
    [self addSubview:m_playerView];
    
    m_trashCanView = [[RTScaleableRoundView alloc] initWithFrame:CGRectZero];
    m_trashCanView.translatesAutoresizingMaskIntoConstraints = NO;
    m_trashCanView.image = [UIImage imageNamed:@"chatmsg_trashcan"];
    m_trashCanView.hidden = YES;
    [self addSubview:m_trashCanView];
    
    m_voluemView = [[ChatMessageVolumePanelView alloc] initWithFrame:CGRectZero];
    m_voluemView.translatesAutoresizingMaskIntoConstraints = NO;
    m_voluemView.hidden = YES;
    [self addSubview:m_voluemView];
    
    
    
    self.statusLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLbl.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLbl.text = @"按住说话";
    self.statusLbl.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.statusLbl];
    
    
    m_circleView = [[CircleView alloc] initWithFrame:CGRectMake(0, 0, kPlayerBtnSz + 3, kPlayerBtnSz + 3)];
    m_circleView.translatesAutoresizingMaskIntoConstraints = NO;
    m_circleView.strokeColor = kStyleColor;
    m_circleView.hidden = YES;
    [self addSubview:m_circleView];
    
    
    m_playerBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [m_playerBtn setBackgroundImage:[UIImage imageNamed:@"chatmsg_play"] forState:UIControlStateNormal];
    [m_playerBtn addTarget:self action:@selector(playerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    m_playerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    m_playerBtn.hidden = YES;
    [self addSubview:m_playerBtn];
    
    m_cancelBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [m_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [m_cancelBtn setTitleColor:kStyleColor forState:UIControlStateNormal];
    [m_cancelBtn addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    m_cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    m_cancelBtn.hidden = YES;
    [self addSubview:m_cancelBtn];
    
    m_sendBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    m_sendBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [m_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [m_sendBtn setTitleColor:kStyleColor forState:UIControlStateNormal];
    [m_sendBtn addTarget:self action:@selector(sendBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    m_sendBtn.hidden = YES;
    [self addSubview:m_sendBtn];
    
    
    [self setupConstraints];
    [self layoutIfNeeded];
}

- (void)setupConstraints {
    NSLayoutConstraint *volumeViewCenterContraint = [NSLayoutConstraint constraintWithItem:m_voluemView
                                                                                 attribute:NSLayoutAttributeCenterX
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self
                                                                                 attribute:NSLayoutAttributeCenterX
                                                                                multiplier:1 constant:0];
    [self addConstraint:volumeViewCenterContraint];
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(m_voluemView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[m_voluemView]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    NSLayoutConstraint *volumeViewHeight = [NSLayoutConstraint constraintWithItem:m_voluemView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1 constant:30.0f];
    [self addConstraint:volumeViewHeight];
    
    NSLayoutConstraint *volumeViewWidth = [NSLayoutConstraint constraintWithItem:m_voluemView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:159.0f];
    [self addConstraint:volumeViewWidth];
    
    NSLayoutConstraint *statusLblLeftConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:m_voluemView
                                                                               attribute:NSLayoutAttributeLeft
                                                                              multiplier:1.0f
                                                                                constant:0];
    [self addConstraint:statusLblLeftConstraint];
    
    NSLayoutConstraint *statusLblTopConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:m_voluemView
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0f
                                                                               constant:0];
    [self addConstraint:statusLblTopConstraint];
    
    NSLayoutConstraint *statusLblRightConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:m_voluemView
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1.0f
                                                                                 constant:0];
    [self addConstraint:statusLblRightConstraint];
    
    NSLayoutConstraint *statusLblBottomConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:m_voluemView
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0f
                                                                                  constant:0];
    [self addConstraint:statusLblBottomConstraint];
    
    
    NSLayoutConstraint *playerViewCenterXconstraint = [NSLayoutConstraint constraintWithItem:m_playerView
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self
                                                                                   attribute:NSLayoutAttributeLeft
                                                                                  multiplier:1.0
                                                                                    constant:kPlayerViewSz];
    [self addConstraint:playerViewCenterXconstraint];
    NSLayoutConstraint *playerViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:m_playerView
                                                                                   attribute:NSLayoutAttributeCenterY
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:m_voluemView
                                                                                   attribute:NSLayoutAttributeBottom
                                                                                  multiplier:1
                                                                                    constant:kPlayerViewSz];
    [self addConstraint:playerViewCenterYConstraint];
    
    m_playerViewHeightConstaint = [NSLayoutConstraint constraintWithItem:m_playerView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:40.0f];
    [self addConstraint:m_playerViewHeightConstaint];
    
    m_playerViewWidthConstaint = [NSLayoutConstraint constraintWithItem:m_playerView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0f
                                                               constant:40.0f];
    [self addConstraint:m_playerViewWidthConstaint];
    
    
    // set transh can view.
    
    NSLayoutConstraint *trashCanViewCenterXconstraint = [NSLayoutConstraint constraintWithItem:m_trashCanView
                                                                                     attribute:NSLayoutAttributeCenterX
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self
                                                                                     attribute:NSLayoutAttributeRight
                                                                                    multiplier:1.0
                                                                                      constant:-kTrashCanViewSz];
    
    [self addConstraint:trashCanViewCenterXconstraint];
    
    NSLayoutConstraint *trashCanViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:m_trashCanView
                                                                                     attribute:NSLayoutAttributeCenterY
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:m_voluemView
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                    multiplier:1
                                                                                      constant:kTrashCanViewSz];
    [self addConstraint:trashCanViewCenterYConstraint];
    
    m_trashCanHeightConstaint = [NSLayoutConstraint constraintWithItem:m_trashCanView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:40.0f];
    [self addConstraint:m_trashCanHeightConstaint];
    
    m_trashCanWidthConstaint = [NSLayoutConstraint constraintWithItem:m_trashCanView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0f
                                                             constant:40.0f];
    [self addConstraint:m_trashCanWidthConstaint];
    
    // set speaker btn.
    NSLayoutConstraint *speakeBtnCenterXConstraint = [NSLayoutConstraint constraintWithItem:m_speakerBtn
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                 multiplier:1.0f
                                                                                   constant:0];
    [self addConstraint:speakeBtnCenterXConstraint];
    
    viewsDictionary = NSDictionaryOfVariableBindings(m_speakerBtn, m_voluemView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[m_voluemView]-[m_speakerBtn]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    NSLayoutConstraint *speakerBtnHeightConstraint = [NSLayoutConstraint constraintWithItem:m_speakerBtn
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1.0f
                                                                                   constant:kSpeakerBtnSz];
    [self addConstraint:speakerBtnHeightConstraint];
    
    NSLayoutConstraint *speakerBtnWidthConstaint = [NSLayoutConstraint constraintWithItem:m_speakerBtn
                                                                                attribute:NSLayoutAttributeWidth
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1.0f
                                                                                 constant:kSpeakerBtnSz];
    [self addConstraint:speakerBtnWidthConstaint];
    
    // set m_directionImgView constraint.
    NSLayoutConstraint *directionImgViewLeftContraint = [NSLayoutConstraint constraintWithItem:m_directionImgView
                                                                                     attribute:NSLayoutAttributeLeft
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:m_playerView
                                                                                     attribute:NSLayoutAttributeCenterX
                                                                                    multiplier:1.0f
                                                                                      constant:0];
    [self addConstraint:directionImgViewLeftContraint];
    
    NSLayoutConstraint *directionImgTopViewContraint = [NSLayoutConstraint constraintWithItem:m_directionImgView
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_playerView
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                   multiplier:1.0f
                                                                                     constant:0];
    [self addConstraint:directionImgTopViewContraint];
    
    NSLayoutConstraint *directionImgBottomConstraint = [NSLayoutConstraint constraintWithItem:m_directionImgView
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_speakerBtn
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                   multiplier:1.0f
                                                                                     constant:0];
    [self addConstraint:directionImgBottomConstraint];
    
    NSLayoutConstraint *directImgRightConstraint = [NSLayoutConstraint constraintWithItem:m_directionImgView
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:m_trashCanView
                                                                                attribute:NSLayoutAttributeCenterX
                                                                               multiplier:1.0f
                                                                                 constant:0];
    [self addConstraint:directImgRightConstraint];
    
    NSLayoutConstraint *playerBtnTopConstraint = [NSLayoutConstraint constraintWithItem:m_playerBtn
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:m_speakerBtn
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0f constant:0];
    [self addConstraint:playerBtnTopConstraint];
    

    NSLayoutConstraint *playerBtnLeftConstraint = [NSLayoutConstraint constraintWithItem:m_playerBtn
                                                                              attribute:NSLayoutAttributeLeft
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:m_speakerBtn
                                                                              attribute:NSLayoutAttributeLeft
                                                                             multiplier:1.0f constant:0];
    [self addConstraint:playerBtnLeftConstraint];
    
    NSLayoutConstraint *playerBtnRightConstraint = [NSLayoutConstraint constraintWithItem:m_playerBtn
                                                                               attribute:NSLayoutAttributeRight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:m_speakerBtn
                                                                               attribute:NSLayoutAttributeRight
                                                                              multiplier:1.0f constant:0];
    [self addConstraint:playerBtnRightConstraint];
    
    NSLayoutConstraint *playerBtnBottomConstraint = [NSLayoutConstraint constraintWithItem:m_playerBtn
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:m_speakerBtn
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1.0f constant:0];
    [self addConstraint:playerBtnBottomConstraint];
    
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
                                                                                constant:-1.0];
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

- (void)setVolumeLevel:(CGFloat)level {
    m_voluemView.ratio = level;
}

- (void)setVolumeStatusLblText:(NSString *)text {
    m_voluemView.timeLbl.text = text;
}

#pragma mark - private method

- (void)scalePlayerView:(CGPoint)pt {
    CGFloat speakerToPlayerDistance = [self distanceBetweenPoint:m_speakerBtn.center otherPoint:m_playerView.center];
    CGFloat toPlayerDistance = [self distanceBetweenPoint:pt otherPoint:m_playerView.center];
    CGFloat l = kPlayerViewSz * (speakerToPlayerDistance /toPlayerDistance);
    if (l > kPlayerViewMaxSz) {
        l = kPlayerViewMaxSz;
    }
    if (l < kPlayerViewSz) {
        l = kPlayerViewSz;
    }
    m_playerViewHeightConstaint.constant = l;
    m_playerViewWidthConstaint.constant = l;
    m_playerView.pressed = CGRectContainsPoint(m_playerView.frame, pt);
    [m_playerView layoutIfNeeded];
}

- (void)scaleTrashView:(CGPoint)pt {
    CGFloat speakerToTrashCanDistance = [self distanceBetweenPoint:m_speakerBtn.center otherPoint:m_trashCanView.center];
    CGFloat toTrashDistance = [self distanceBetweenPoint:pt otherPoint:m_trashCanView.center];
    CGFloat l = kTrashCanViewSz * (speakerToTrashCanDistance / toTrashDistance);
    if (l > kTrashCanViewMaxSz) {
        l = kTrashCanViewMaxSz;
    }
    
    if (l < kTrashCanViewSz) {
        l = kTrashCanViewSz;
    }
    
    m_trashCanHeightConstaint.constant = l;
    m_trashCanWidthConstaint.constant = l;
    m_trashCanView.pressed = CGRectContainsPoint(m_trashCanView.frame, pt);
    [m_trashCanView layoutIfNeeded];
    
}

- (CGFloat)distanceBetweenPoint:(CGPoint)pt otherPoint:(CGPoint)otherPt {
    CGFloat xDist = (pt.x - otherPt.x);
    CGFloat yDist = (pt.y - otherPt.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

- (void)prepareRecordMode {
    self.statusLbl.text = @"正在准备";
}

- (void)showRecordingMode {
    m_playerView.hidden = NO;
    m_trashCanView.hidden = NO;
    m_directionImgView.hidden = NO;
    m_voluemView.hidden = NO;
    self.statusLbl.hidden = YES;
}

- (void)showNoRecordMode {
    self.statusLbl.text = @"按住说话";
    self.statusLbl.hidden = NO;
    
    m_playerView.hidden = YES;
    m_playerView.pressed = NO;
    m_playerViewHeightConstaint.constant = kPlayerViewSz;
    m_playerViewWidthConstaint.constant = kPlayerViewSz;
    [m_playerView layoutIfNeeded];
    
    m_trashCanView.hidden = YES;
    m_trashCanHeightConstaint.constant = kTrashCanViewSz;
    m_trashCanWidthConstaint.constant = kTrashCanViewSz;
    m_trashCanView.pressed = NO;
    [m_trashCanView layoutIfNeeded];
    
    m_directionImgView.hidden = YES;
    m_voluemView.hidden = YES;
}




#pragma mark <RTMicButtonDelegate>
- (void)RTMicButton:(RTMicButton *)btn TouchDownAtParentPoint:(CGPoint)pt {
    [self showRecordingMode];
    [self handleSpeakerBtnPressDown];
    
}

- (void)RTMicButton:(RTMicButton *)btn DragInsideAtParentPoint:(CGPoint)pt {
    
    pt.x > m_speakerBtn.center.x ? [self scaleTrashView:pt] : [self scalePlayerView:pt];
    
}

- (void)RTMicButton:(RTMicButton *)btn DragOutsideAtParentPoint:(CGPoint)pt {
    pt.x > m_speakerBtn.center.x ? [self scaleTrashView:pt] : [self scalePlayerView:pt];
}

- (void)RTMicButton:(RTMicButton *)btn TouchUpInsideAtParentPoint:(CGPoint)pt {
    [self showNoRecordMode];
    BOOL isInBtn = CGRectContainsPoint(btn.frame, pt);
    if (isInBtn) {
        [self handleRecordComplete];
        return;
    }
    
    BOOL isInPlayerView = CGRectContainsPoint(m_playerView.frame, pt);
    if (isInPlayerView) {
        [self handleDraginPlayerView];
        return;
    }
    
    BOOL isInTrashCanView = CGRectContainsPoint(m_trashCanView.frame, pt);
    if (isInTrashCanView) {
        NSLog(@"in trashcan");
        [self handleTrashcanbtnPressDown];
        return;
    }
}

- (void)RTMicButton:(RTMicButton *)btn TouchUpOutsideAtparentPoint:(CGPoint)pt {
    if (m_trashCanView.pressed) {
        NSLog(@"trash can view");
        [self showNoRecordMode];
        [self handleTrashcanbtnPressDown];
        return;
    }
    if (m_playerView.pressed) {
        [self handleDraginPlayerView];
        return;
    }
    
    [self handleRecordComplete];
    [self showNoRecordMode];
}

- (void)handleDraginPlayerView {
    m_playerBtn.hidden = NO;
    m_circleView.hidden = NO;
    m_cancelBtn.hidden = NO;
    m_sendBtn.hidden = NO;
    m_playerView.hidden = YES;
    m_trashCanView.hidden = YES;
    [self setVolumeLevel:0];
    [self.recorder stop];
    NSLog(@"in player");
}

- (void)handleSpeakerBtnPressDown {
    AudioRecorder *recorder = [AudioRecorder shareRecorder];
    recorder.delegate = self;
    if (!self.audioDirectory) {
        self.audioDirectory = NSTemporaryDirectory();
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@.m4a", [NSUUID uuid]];
    self.audioPath = [self.audioDirectory stringByAppendingPathComponent:fileName];
    [recorder recordWithPath:self.audioPath duration:120];
}

- (void)handleTrashcanbtnPressDown {
    [self.recorder stop];
    [self.recorder deleteRecording];
}

- (void)handleRecordComplete {
    NSLog(@"record complete");
    [self.recorder stop];
    if (self.recorder.duration < 0.6f) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(RTMicPanelViewSpeakOver:audioPath:duration:)]) {
        [self.delegate RTMicPanelViewSpeakOver:self audioPath:self.audioPath duration:self.recorder.duration];
    }
    
}


- (void)playerBtnPressed:(UIButton *)playerBtn {
    self.stop = !self.stop;
    if (!self.stop) {
        self.player.delegate = self;
        [self.player playWithPath:self.audioPath];
    } else {
        [self.player stop];
    }
    
    [self layoutIfNeeded];
}

- (void)cancelBtnPressed:(UIButton *)cancelBtn {
    self.statusLbl.text = @"按住说话";
    self.statusLbl.hidden = NO;
    
    m_playerView.hidden = YES;
    m_playerView.pressed = NO;
    m_playerViewHeightConstaint.constant = kPlayerViewSz;
    m_playerViewWidthConstaint.constant = kPlayerViewSz;
    [m_playerView layoutIfNeeded];
    
    m_trashCanView.hidden = YES;
    m_trashCanHeightConstaint.constant = kTrashCanViewSz;
    m_trashCanWidthConstaint.constant = kTrashCanViewSz;
    m_trashCanView.pressed = NO;
    [m_trashCanView layoutIfNeeded];
    
    m_directionImgView.hidden = YES;
    m_voluemView.hidden = YES;
    m_playerBtn.hidden = YES;
    m_circleView.hidden = YES;
    m_cancelBtn.hidden = YES;
    m_sendBtn.hidden = YES;
    self.stop = YES;
}

- (void)sendBtnPressed:(UIButton *)sendBtn {
    if ([self.delegate respondsToSelector:@selector(RTMicPanelViewSpeakOver:audioPath:duration:)]) {
        [self.delegate RTMicPanelViewSpeakOver:self audioPath:self.audioPath duration:self.recorder.duration];
    }
}

- (void)setProgress:(double)progress {
    [m_circleView setStrokeEnd:progress animated:YES];
}

- (void)setStop:(BOOL)stop {
    _stop = stop;
    [m_playerBtn setBackgroundImage:self.stop ? [UIImage imageNamed:@"chatmsg_play"] : [UIImage imageNamed:@"chatmsg_stop"] forState:UIControlStateNormal];
    [m_circleView setStrokeEnd:0 animated:NO];
}

#pragma mark - audio recorder delegate

- (void)AudioRecord:(AudioRecorder *)recorder started:(BOOL)started {
    if (!started) {
        NSLog(@"recorder error on starting");
    }
}

- (void)AudioRecord:(AudioRecorder *)recorder error:(NSError *)error {
    if (error) {
        NSLog(@"recorder error.");
    }
}

- (void)AudioRecord:(AudioRecorder *)recorder recordingDuration:(NSTimeInterval)duration {
    [self setVolumeStatusLblText:[self getText:duration]];
}

- (void)AudioRecord:(AudioRecorder *)recorder recordingLevel:(double)level {
    [self setVolumeLevel:level];
}

- (void)AudioRecord:(AudioRecorder *)recorder end:(BOOL)stop {
    self.duration = recorder.duration;
}

- (NSString *)getText:(NSUInteger) interval {
    NSInteger minutes = interval / 60;
    NSInteger seconds = interval % 60;
    
    NSString *ret = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    return ret;
}

#pragma mark - audio player delegate.

- (void)AudioPlayer:(AudioPlayer *)player playerDuration:(NSTimeInterval)duration {
    [self setVolumeStatusLblText:[self getText:duration]];
    self.progress = duration/self.duration;
}

- (void)AudioPlayer:(AudioPlayer *)player playerLevel:(double)level {
    [self setVolumeLevel:level];
}

- (void)AudioPlayer:(AudioPlayer *)player end:(BOOL)suc {
    self.stop = YES;
}


@end
