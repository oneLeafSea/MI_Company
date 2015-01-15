//
//  ChatMessage.h
//  IM
//
//  Created by 郭志伟 on 15-1-14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "Request.h"

typedef NS_ENUM(UInt32, ChatMessageType) {
    ChatMessageTypeNormal,      // 普通消息
    ChatMessageTypeGroupChat    // 群聊
};

@interface ChatMessage : Request

@property NSString      *from;
@property NSString      *fromRes;
@property NSString      *to;
@property NSString      *toRes;
@property NSString      *time;
@property ChatMessageType chatMsgType;
@property NSMutableDictionary *body;

- (instancetype) initWithData:(NSData *)data;

@end
