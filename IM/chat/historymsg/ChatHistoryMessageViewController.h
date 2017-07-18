//
//  ChatHistoryMessageViewController.h
//  IM
//
//  Created by 郭志伟 on 15/4/28.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTMessagesViewController.h"

#import "RTMessages.h"
#import "RTChatModel.h"
#import "ChatMessage.h"

@interface ChatHistoryMessageViewController : RTMessagesViewController


@property(nonatomic, strong) RTChatModel *data;
@property(nonatomic, strong) NSString *talkingId;
@property(nonatomic, strong) NSString *talkingname;
@property ChatMessageType chatMsgType;

@end
