//
//  RTChatModel.m
//  IM
//
//  Created by 郭志伟 on 15/7/21.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTChatModel.h"

#import "ChatMessage.h"
#import "RTMessage.h"
#import "AppDelegate.h"
#import "RTAudioMediaItem.h"
#import "RTFileMediaItem.h"

#import "NSDate+Common.h"
#import "UIImage+Common.h"
#import "ChatMessageNotification.h"
#import "RTFileTransfer.h"
#import "RTAudioMediaItem.h"
#import "Utils.h"
#import "UIColor+Hexadecimal.h"
#import "RTVideoChatMediaItem.h"

static NSString *kDateFormater = @"yyyy-MM-dd HH:mm:ss.SSSSSS";

@implementation RTChatModel

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.messages = [[NSMutableArray alloc] init];
    RTMessagesBubbleImageFactory *bubbleFactory = [[RTMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithHex:@"#b2e866"]];
}

- (instancetype)initWithMsgs:(NSArray *)msgs {
    if ([self init]) {
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
            NSNumber *b64 = [msg.body objectForKey:@"b64"];
            BOOL b = [b64 boolValue];
            NSString *content = [msg.body objectForKey:@"content"];
            if (b) {
                NSString *t = [Utils decodeBase64String:content];
                if (t.length == 0) {
                    content = [Utils decodeBase64String:content];
                    NSLog(@"error");
                } else {
                    content = t;
                }
            }
            if (content == nil) {
                return;
            }
            NSString *displayName = [msg.body objectForKey:@"fromname"];
            if (displayName == nil) {
                displayName = @"未知";
            }
            NSDate *date = [NSDate dateWithFormater:kDateFormater stringTime:msg.time];
            RTMessage *rtMsg = [[RTMessage alloc] initWithSenderId:msg.from
                                                    senderDisplayName:displayName
                                                                 date:date
                                                              text:content];
            
            rtMsg.status = (UInt32)msg.status;
            [self.messages addObject:rtMsg];
        }
        
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"image"]) {
            NSDate *date = [NSDate dateWithFormater:kDateFormater stringTime:msg.time];
            RTPhotoMediaItem *photoItem = [[RTPhotoMediaItem alloc] initWithMaskAsOutgoing:[msg.from isEqualToString:USER.uid] ? YES : NO];
            NSString *uuid = [msg.body objectForKey:@"uuid"];
            photoItem.status = (UInt32)msg.status;
            if (photoItem.status == RTPhotoMediaItemStatusSending ||
                photoItem.status == RTPhotoMediaItemStatusSent ||
                photoItem.status == RTPhotoMediaItemStatusSendError) {
                NSString *thumbImgPath = [[USER.filePath stringByAppendingPathComponent:uuid] stringByAppendingString:@"_thumb"];
                photoItem.thumbUrl = [NSURL fileURLWithPath:thumbImgPath];
                photoItem.orgUrl = [NSURL fileURLWithPath:[USER.filePath stringByAppendingPathComponent:uuid]];
            } else if (photoItem.status == RTPhotoMediaItemStatusRecved ||
                       photoItem.status == RTPhotoMediaItemStatusRecvError ||
                       photoItem.status == RTPhotoMediaItemStatusRecving ||
                       photoItem.status == RTPhotoMediaItemStatusUnkown){
                NSString *thumbUrl = [USER.imgThumbServerUrl stringByAppendingPathComponent:uuid];
                photoItem.thumbUrl = [NSURL URLWithString:thumbUrl];
                photoItem.orgUrl = [NSURL URLWithString:[USER.fileDownloadSvcUrl stringByAppendingPathComponent:uuid]];
            }
            NSString *displayName = [msg.body objectForKey:@"fromname"];
            if (displayName.length == 0) {
                displayName = @"未知";
            }
            RTMessage *rtMsg = [[RTMessage alloc] initWithSenderId:msg.from
                                                 senderDisplayName:displayName
                                                              date:date
                                                             media:photoItem];
            [self.messages addObject:rtMsg];
            
            
        }
        
        if ([[msg.body objectForKey:@"type"] isEqualToString:@"voice"]) {
            NSString *uuid = [msg.body objectForKey:@"uuid"];
            NSString *voicePath = [USER.audioPath stringByAppendingPathComponent:uuid];
            unsigned long long  duration = [[msg.body objectForKey:@"duration"] integerValue];
            RTAudioMediaItem *voiceItem = [[RTAudioMediaItem alloc] initWithMaskAsOutgoing:[msg.from isEqualToString:USER.uid] ? YES : NO];
            voiceItem.status = (UInt32)msg.status;
            voiceItem.audioUrl = voicePath;
            voiceItem.duration = duration;
            if (voiceItem.status == RTPhotoMediaItemStatusUnkown) {
                if (![[NSFileManager defaultManager] fileExistsAtPath:voiceItem.audioUrl]) {
                    [RTFileTransfer downFileWithServerUrl:USER.fileDownloadSvcUrl fileDir:USER.audioPath fileName:uuid token:USER.token key:USER.key iv:USER.iv progress:^(double progress) {
                        
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
            NSDate *date = [NSDate dateWithFormater:kDateFormater stringTime:msg.time];
            RTMessage *voiceMsg = [[RTMessage alloc] initWithSenderId:msg.from senderDisplayName:[msg.body objectForKey:@"fromname"] date:date media:voiceItem];
            [self.messages addObject:voiceMsg];
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
            RTVideoChatMediaItem *item = [[RTVideoChatMediaItem alloc] initWithTip:tip];
            item.appliesMediaViewMaskAsOutgoing = [USER.uid isEqualToString:msg.from];
            RTMessage *videoChatMsg = [[RTMessage alloc] initWithSenderId:msg.from senderDisplayName:[msg.body objectForKey:@"fromname"] date:date media:item];
            [self.messages addObject:videoChatMsg];
        }
    }];
    
    return YES;
}

@end
