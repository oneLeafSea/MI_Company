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
#import "JSQVideoChatMediaItem.h"
#import "JSQFileMediaItem.h"
#import "NSDate+Common.h"
#import "UIImage+Common.h"
#import "ChatMessageNotification.h"
#import "RTFileTransfer.h"

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
            photoItem.msgId = msg.qid;
            if (msg.status == ChatMessageStatusRecved || msg.status == ChatMessageStatusSent) {
                photoItem.image = [UIImage imageWithContentsOfFile:thumbImgPath];
                photoItem.imgPath = [USER.filePath stringByAppendingPathComponent:uuid];
            } else {
                if ([msg.from isEqualToString:USER.uid]) {
                    __block NSString *imagePath = [USER.filePath stringByAppendingPathComponent:uuid];
                    [RTFileTransfer downFileWithServerUrl:USER.fileDownloadSvcUrl fileDir:USER.filePath fileName:uuid token:USER.token key:USER.key iv:USER.iv progress:nil completion:^(BOOL finished) {
                        NSString *thumbPath = [imagePath stringByAppendingString:@"_thumb"];
                        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                        [image saveToPath:thumbPath sz:CGSizeMake(100.0f, 100.0f)];
                        [USER.msgMgr updateMsgWithId:msg.qid status:ChatMessageStatusSent];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageMediaMsgDownload object:msg];
                    }];
                } else {
                    __block NSString *imagePath = [USER.filePath stringByAppendingPathComponent:uuid];
                    [RTFileTransfer downFileWithServerUrl:USER.fileDownloadSvcUrl fileDir:USER.filePath fileName:uuid token:USER.token key:USER.key iv:USER.iv progress:nil completion:^(BOOL finished) {
                        NSString *thumbPath = [imagePath stringByAppendingString:@"_thumb"];
                        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                        [image saveToPath:thumbPath sz:CGSizeMake(100.0f, 100.0f)];
                        [USER.msgMgr updateMsgWithId:msg.qid status:ChatMessageStatusRecved];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageMediaMsgDownload object:msg];
                    }];
                }
                
            }
            NSDate *date = [NSDate dateWithFormater:kDateFormater stringTime:msg.time];
            JSQMessage *photoMessage = [[JSQMessage alloc] initWithSenderId:msg.from
                                                          senderDisplayName:[msg.body objectForKey:@"fromname"] ? [msg.body objectForKey:@"fromname"] : @"" date:date media:photoItem];
            [self.messages addObject:photoMessage];
        }
        
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"voice"]) {
            NSString *uuid = [msg.body objectForKey:@"uuid"];
            NSString *voicePath = [USER.audioPath stringByAppendingPathComponent:uuid];
            
            BOOL isReady = ((msg.status == ChatMessageStatusRecved) || (msg.status == ChatMessageStatusSent));
            unsigned long long  duration = [[msg.body objectForKey:@"duration"] integerValue];
            
            JSQVoiceMediaItem *voiceItem = [[JSQVoiceMediaItem alloc] initWithFilePath:voicePath isReady:isReady duration:duration outgoing:[msg.from isEqualToString:USER.uid] ? YES : NO msgId:msg.qid];
            
            if (!isReady) {
                if ([msg.from isEqualToString:USER.uid]) {
//                    [USER.fileTransfer downloadFileName:uuid urlString:USER.fileDownloadSvcUrl checkUrlString:USER.fileCheckUrl options:@{@"token":USER.token, @"signature":USER.signature, @"path":voicePath, @"key":USER.key, @"iv":USER.iv} completion:^(BOOL finished, NSError *error) {
//                        if (finished) {
//                            [USER.msgMgr updateMsgWithId:msg.qid status:ChatMessageStatusRecved];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageMediaMsgDownload object:msg];
//                        }
//                    }];
                    [RTFileTransfer downFileWithServerUrl:USER.fileDownloadSvcUrl fileDir:voicePath fileName:uuid token:USER.token key:USER.key iv:USER.iv progress:nil completion:^(BOOL finished) {
                        if (finished) {
                            [USER.msgMgr updateMsgWithId:msg.qid status:ChatMessageStatusRecved];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageMediaMsgDownload object:msg];
                        }
                    }];
                } else {
//                    [USER.fileTransfer downloadFileName:uuid urlString:USER.fileDownloadSvcUrl checkUrlString:USER.fileCheckUrl options:@{@"token":USER.token, @"signature":USER.signature, @"path":voicePath, @"key":USER.key, @"iv":USER.iv} completion:^(BOOL finished, NSError *error) {
//                        if (finished) {
//                            [USER.msgMgr updateMsgWithId:msg.qid status:ChatMessageStatusRecved];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageMediaMsgDownload object:msg];
//                        }
//                    }];
                    [RTFileTransfer downFileWithServerUrl:USER.fileDownloadSvcUrl fileDir:voicePath fileName:uuid token:USER.token key:USER.key iv:USER.iv progress:nil completion:^(BOOL finished) {
                        if (finished) {
                            [USER.msgMgr updateMsgWithId:msg.qid status:ChatMessageStatusRecved];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageMediaMsgDownload object:msg];
                        }

                    }];
                }
                
                }

            
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
            JSQMessage *fileMsg = [[JSQMessage alloc] initWithSenderId:msg.from senderDisplayName:[msg.body objectForKey:@"fromname"] date:date media:fileItem];
            
            [self.messages addObject:fileMsg];
        }
        
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"videochat"]) {
            NSString *tip = @"通话未接通";
            NSNumber *n = [msg.body objectForKey:@"connected"];
            BOOL connected = [n boolValue];
            NSUInteger interval = [[msg.body objectForKey:@"interval"] integerValue];
            if (connected) {
                tip = [NSString stringWithFormat:@"通话时长%02d:%02d", interval/60, interval%60];
            }
            NSDate *date = [NSDate dateWithFormater:kDateFormater stringTime:msg.time];
            JSQVideoChatMediaItem *item = [[JSQVideoChatMediaItem alloc] initWithTip:tip];
            item.appliesMediaViewMaskAsOutgoing = [USER.uid isEqualToString:msg.from];
            JSQMessage *videoChatMsg = [[JSQMessage alloc] initWithSenderId:msg.from senderDisplayName:[msg.body objectForKey:@"fromname"] date:date media:item];
            [self.messages addObject:videoChatMsg];
        }
        }];
    return YES;
}

@end
