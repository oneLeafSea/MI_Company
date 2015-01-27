//
//  ChatModel.m
//  IM
//
//  Created by 郭志伟 on 15-1-15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatModel.h"
#import "ChatMessage.h"
#import "JSQMessage.h"

@implementation ChatModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        JSQMessagesAvatarImage *mineImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"male"]
                                                                                       diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        self.avatars = @{
                         @"gzw":mineImage,
                         @"xyy":mineImage
                         };
        self.messages = [[NSMutableArray alloc] init];
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    return self;
}

- (instancetype)initWithMsgs:(NSArray *)msgs {
    if (self = [self init]) {
        if (![self parseMsgs:msgs]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)parseMsgs:(NSArray *)msgs {
    [msgs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ChatMessage *msg = obj;
        JSQMessage *jsqMsg = [JSQMessage messageWithSenderId:msg.from displayName:[msg.body objectForKey:@"fromname"] text:[msg.body objectForKey:@"content"]];
        [self.messages addObject:jsqMsg];
    }];
    return YES;
}

@end
