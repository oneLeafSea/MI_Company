//
//  ChatMessageControllerInfo.h
//  IM
//
//  Created by 郭志伟 on 15-1-22.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"


@interface ChatMessageControllerInfo : NSObject

@property ChatMessageType msgType;
@property NSString *talkingId;
@property NSString *talkingName;

@end
