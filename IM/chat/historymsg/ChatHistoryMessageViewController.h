//
//  ChatHistoryMessageViewController.h
//  IM
//
//  Created by 郭志伟 on 15/4/28.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "JSQMessagesViewController.h"

#import "JSQMessages.h"
#import "ChatModel.h"
#import "ChatMessage.h"

@interface ChatHistoryMessageViewController : JSQMessagesViewController


@property(nonatomic, strong) ChatModel *data;
@property(nonatomic, strong) NSString *talkingId;
@property(nonatomic, strong) NSString *talkingname;
@property ChatMessageType chatMsgType;

@end
