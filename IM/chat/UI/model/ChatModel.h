//
//  ChatModel.h
//  IM
//
//  Created by 郭志伟 on 15-1-15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"

@interface ChatModel : NSObject


- (instancetype)initWithMsgs:(NSArray *)msgs;

@property (nonatomic, strong) NSDictionary *avatars;
@property (nonatomic, strong) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic) NSDictionary *users;


@end
