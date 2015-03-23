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
#import "AppDelegate.h"
#import "JSQVoiceMediaItem.h"
#import "JSQFileMediaItem.h"
#import "NSDate+Common.h"

static NSString *kDateFormater = @"yyyy-MM-dd HH:mm:ss.SSSSSS";

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
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"text"]) {
//            JSQMessage *jsqMsg = [JSQMessage messageWithSenderId:msg.from displayName:[msg.body objectForKey:@"fromname"] text:[msg.body objectForKey:@"content"]];
            NSDate *date = [NSDate dateWithFormater:kDateFormater stringTime:msg.time];
            JSQMessage *jsqMsg = [[JSQMessage alloc] initWithSenderId:msg.from
                                                    senderDisplayName:[msg.body objectForKey:@"fromname"]
                                                                 date:date text:[msg.body objectForKey:@"content"]];
            
            [self.messages addObject:jsqMsg];
        }
        
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"image"]) {
            NSString *uuid = [msg.body objectForKey:@"uuid"];
            NSString *thumbImgPath = [[USER.filePath stringByAppendingPathComponent:uuid] stringByAppendingString:@"_thumb"];
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:[msg.from isEqualToString:USER.uid] ? YES : NO];
            if (msg.status == ChatMessageStatusRecved || msg.status == ChatMessageStatusSent) {
                photoItem.image = [UIImage imageWithContentsOfFile:thumbImgPath];
                photoItem.imgPath = [USER.filePath stringByAppendingPathComponent:uuid];
            }
//            JSQMessage *photoMessage = [JSQMessage messageWithSenderId:msg.from
//                                                           displayName:[msg.body objectForKey:@"fromname"]
//                                                                 media:photoItem];
            NSDate *date = [NSDate dateWithFormater:kDateFormater stringTime:msg.time];
            JSQMessage *photoMessage = [[JSQMessage alloc] initWithSenderId:msg.from
                                                          senderDisplayName:[msg.body objectForKey:@"fromname"] date:date media:photoItem];
            [self.messages addObject:photoMessage];
        }
        
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"voice"]) {
            NSString *uuid = [msg.body objectForKey:@"uuid"];
            NSString *voicePath = [USER.audioPath stringByAppendingPathComponent:uuid];
            
            BOOL isReady = ((msg.status == ChatMessageStatusRecved) || (msg.status == ChatMessageStatusSent));
            unsigned long long  duration = [[msg.body objectForKey:@"duration"] integerValue];
            
            JSQVoiceMediaItem *voiceItem = [[JSQVoiceMediaItem alloc] initWithFilePath:voicePath isReady:isReady duration:duration outgoing:[msg.from isEqualToString:USER.uid] ? YES : NO];
            
            NSDate *date = [NSDate dateWithFormater:kDateFormater stringTime:msg.time];
            JSQMessage *voiceMsg = [[JSQMessage alloc] initWithSenderId:msg.from senderDisplayName:[msg.body objectForKey:@"fromname"] date:date media:voiceItem];
            [self.messages addObject:voiceMsg];
        }
        
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"file"]) {
            NSString *uuid = [msg.body objectForKey:@"uuid"];
            NSString *filePath = [USER.filePath stringByAppendingPathComponent:uuid];
            BOOL isDownloaded = ((msg.status == ChatMessageStatusRecved) || (msg.status == ChatMessageStatusSent));
            NSString* sz = [msg.body objectForKey:@"filesize"];
            NSString *fileName = [msg.body objectForKey:@"filename"];
            unsigned long long filesz = [sz integerValue];
            JSQFileMediaItem *fileItem = [[JSQFileMediaItem alloc] initWithFilePath:filePath fileSz:filesz uuid:uuid fileName:fileName isReady:isDownloaded outgoing:[msg.from isEqualToString:USER.uid] ? YES : NO];
            NSDate *date = [NSDate dateWithFormater:kDateFormater stringTime:msg.time];
//            JSQMessage *fileMsg = [JSQMessage messageWithSenderId:msg.from displayName:[msg.body objectForKey:@"fromname"] media:fileItem];
            JSQMessage *fileMsg = [[JSQMessage alloc] initWithSenderId:msg.from senderDisplayName:[msg.body objectForKey:@"fromname"] date:date media:fileItem];
            
            [self.messages addObject:fileMsg];
        }

        
        }];
    return YES;
}

@end
