//
//  ChatViewController.h
//  IM
//
//  Created by 郭志伟 on 15-1-15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "JSQMessages.h"
#import "ChatModel.h"
#import "ChatMessage.h"

@interface ChatViewController : JSQMessagesViewController

@property(nonatomic, strong) ChatModel *data;
@property(nonatomic, strong) NSString *talkingId;
@property(nonatomic, strong) NSString *talkingname;
@property ChatMessageType chatMsgType;

@end
