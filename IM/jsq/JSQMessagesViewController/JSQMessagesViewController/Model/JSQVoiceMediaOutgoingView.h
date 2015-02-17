//
//  JSQVoiceMediaOutgoingView.h
//  IM
//
//  Created by 郭志伟 on 15-2-15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSQVoiceMediaOutgoingView : UIView
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *speakerView;
@property (weak, nonatomic) IBOutlet UILabel *durationLbl;

@end
