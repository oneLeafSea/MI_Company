//
//  ChatMessageSpeakerPanelView.m
//  testAudio
//
//  Created by 郭志伟 on 15-2-10.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageSpeakerPanelView.h"

#import "SpeakerButton.h"
#import "ScaleableRoundView.h"
#import "ChatMessageVolumePanelView.h"

static const double kPlayerViewSz = 40.0f;
static const double kPlayerViewMaxSz = 60.0f;
static const double kTrashCanViewSz = 40.0f;
static const double kTrashCanViewMaxSz = 60.0f;
static const double kSpeakerBtnSz = 90.0f;

@interface ChatMessageSpeakerPanelView() <SpeakerButtonDelegate> {
    SpeakerButton               *m_speakerBtn;
    ScaleableRoundView          *m_playerView;
    ScaleableRoundView          *m_trashCanView;
    ChatMessageVolumePanelView  *m_voluemView;
    UIImageView                 *m_directionImgView;
    NSLayoutConstraint          *m_playerViewWidthConstaint;
    NSLayoutConstraint          *m_playerViewHeightConstaint;
    NSLayoutConstraint          *m_trashCanWidthConstaint;
    NSLayoutConstraint          *m_trashCanHeightConstaint;
//    UIActivityIndicatorView     *m_indicatorView;
}
@end

@implementation ChatMessageSpeakerPanelView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void) awakeFromNib {
    [self setup];
}

- (void)setup {
    self.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    
    m_directionImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatmsg_move_direction"]];
    m_directionImgView.translatesAutoresizingMaskIntoConstraints = NO;
    m_directionImgView.hidden = YES;
    [self addSubview:m_directionImgView];
    
    m_speakerBtn = [[SpeakerButton alloc] initWithFrame:CGRectZero];
    m_speakerBtn.delegate = self;
    m_speakerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:m_speakerBtn];
    
    m_playerView = [[ScaleableRoundView alloc] initWithFrame:CGRectZero];
    m_playerView.translatesAutoresizingMaskIntoConstraints = NO;
    m_playerView.hidden = YES;
    [self addSubview:m_playerView];
    
    m_trashCanView = [[ScaleableRoundView alloc] initWithFrame:CGRectZero];
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
    
    //    m_indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //    [self addSubview:m_indicatorView];
    
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
    
    // set statusLbl constraint.
//    NSLayoutConstraint *statusLblCenterXConstraint = [NSLayoutConstraint constraintWithItem:_statusLbl
//                                                                           attribute:NSLayoutAttributeCenterX
//                                                                           relatedBy:NSLayoutRelationEqual
//                                                                              toItem:self
//                                                                           attribute:NSLayoutAttributeCenterX
//                                                                          multiplier:1.0
//                                                                            constant:0];
//    statusLblCenterXConstraint.priority = UILayoutPriorityRequired;
//    [self addConstraint:statusLblCenterXConstraint];
//    
//    viewsDictionary = NSDictionaryOfVariableBindings(_statusLbl);
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_statusLbl]"
//                                                                 options:0
//                                                                 metrics:nil
//                                                                   views:viewsDictionary]];
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
    
    // set indicator constraint.
//    viewsDictionary = NSDictionaryOfVariableBindings(m_indicatorView, _statusLbl);
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[m_indicatorView][_statusLbl]" options:0 metrics:nil views:viewsDictionary]];
//    NSLayoutConstraint *constaint = [NSLayoutConstraint constraintWithItem:m_indicatorView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_statusLbl attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
//    [self addConstraint:constaint];
    
    
    // set m_playerView centerX = self.left + 50.0f; height = 40 width = 40.
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




#pragma mark <SpeakerButtonDelegate>
- (void)SpeakerButton:(SpeakerButton *)btn TouchDownAtParentPoint:(CGPoint)pt {
    [self showRecordingMode];
    if ([self.delegate respondsToSelector:@selector(ChatMessageSpeakerPanelSpeakerBtnPressDown:)]) {
        [self.delegate ChatMessageSpeakerPanelSpeakerBtnPressDown:self];
    }
    NSLog(@"pressed down");
}

- (void)SpeakerButton:(SpeakerButton *)btn DragInsideAtParentPoint:(CGPoint)pt {
    
    pt.x > m_speakerBtn.center.x ? [self scaleTrashView:pt] : [self scalePlayerView:pt];
    
}

- (void)SpeakerButton:(SpeakerButton *)btn DragOutsideAtParentPoint:(CGPoint)pt {
    pt.x > m_speakerBtn.center.x ? [self scaleTrashView:pt] : [self scalePlayerView:pt];
}

- (void)SpeakerButton:(SpeakerButton *)btn TouchUpInsideAtParentPoint:(CGPoint)pt {
    [self showNoRecordMode];
    if ([self.delegate respondsToSelector:@selector(ChatMessageSpeakerPanelSpeakOver:)]) {
        
        [self.delegate ChatMessageSpeakerPanelSpeakOver:self];
    }
    NSLog(@"in speaker");
}

- (void)SpeakerButton:(SpeakerButton *)btn TouchUpOutsideAtparentPoint:(CGPoint)pt {
    if (m_trashCanView.pressed) {
        if ([self.delegate respondsToSelector:@selector(ChatMessageSpeakerPanelDragInTrashCanBtn:)]) {
            [self.delegate ChatMessageSpeakerPanelDragInTrashCanBtn:self];
        }
        NSLog(@"trash can view");
        [self showNoRecordMode];
        return;
    }
    if (m_playerView.pressed) {
        if ([self.delegate respondsToSelector:@selector(ChatMessageSpeakerPanelDragInPlayerBtn:)]) {
            [self.delegate ChatMessageSpeakerPanelDragInPlayerBtn:self];
            
        }
        NSLog(@"player view");
        [self showNoRecordMode];
        return;
    }
    NSLog(@"none");
    if ([self.delegate respondsToSelector:@selector(ChatMessageSpeakerPanelSpeakOver:)]) {
        
        [self.delegate ChatMessageSpeakerPanelSpeakOver:self];
    }
    [self showNoRecordMode];
}



@end
