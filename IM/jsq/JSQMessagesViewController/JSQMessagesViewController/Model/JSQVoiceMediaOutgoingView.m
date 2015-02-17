//
//  JSQVoiceMediaOutgoingView.m
//  IM
//
//  Created by 郭志伟 on 15-2-15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "JSQVoiceMediaOutgoingView.h"

@implementation JSQVoiceMediaOutgoingView

- (void)awakeFromNib {
    self.speakerView.animationImages = @[[UIImage imageNamed:@"chatmsg_esj"], [UIImage imageNamed:@"chatmsg_esk"],[UIImage imageNamed:@"chatmsg_esl"]];
    self.speakerView.animationDuration = 0.9;
    self.speakerView.animationRepeatCount = 0;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
