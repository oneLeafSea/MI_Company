//
//  RTChatViewController.h
//  IM
//
//  Created by 郭志伟 on 15/7/14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTMessagesViewController.h"
#import "ChatMessage.h"


@interface RTChatViewController : RTMessagesViewController

@property(nonatomic, strong) NSString *talkingId;
@property(nonatomic, strong) NSString *talkingname;
@property(nonatomic, assign) ChatMessageType chatMsgType;

@end
