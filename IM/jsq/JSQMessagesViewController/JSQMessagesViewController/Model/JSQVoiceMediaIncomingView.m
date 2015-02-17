//
//  JSQVoiceMediaIncomingView.m
//  IM
//
//  Created by 郭志伟 on 15-2-15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "JSQVoiceMediaIncomingView.h"

@implementation JSQVoiceMediaIncomingView

- (void)awakeFromNib {
    self.speakerImgView.animationImages = @[[UIImage imageNamed:@"chatmsg_esg"], [UIImage imageNamed:@"chatmsg_esh"],[UIImage imageNamed:@"chatmsg_esi"]];
    self.speakerImgView.animationDuration = 0.9;
    self.speakerImgView.animationRepeatCount = 0;
    
}

@end
