//
//  ChatMessageMgr.m
//  IM
//
//  Created by 郭志伟 on 15-1-14.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ChatMessageMgr.h"
#import "MessageConstants.h"
#import "IMAck.h"
#import "NSDate+Common.h"
#import "ChatMessageNotification.h"
#import "ChatMesssageBox.h"
#import "ChatMessageTb.h"
#import "LogLevel.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "UIImage+Common.h"
#import "NSUUID+StringUUID.h"




@interface ChatMessageMgr() {
    __weak FMDatabaseQueue *m_dbq;
    __weak Session         *m_session;
    NSString               *m_sid;
    ChatMesssageBox        *m_msgBox;
    ChatMessageTb          *m_msgTb;
}
@end

@implementation ChatMessageMgr

- (instancetype)initWithSelfUid:(NSString *)sid
                            dbq:(FMDatabaseQueue *)dbq
                        session:(Session *)session {
    if (self = [super init]) {
        m_sid = [sid copy];
        m_dbq = dbq;
        m_session = session;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL) setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIMMessageAck:) name:kIMAckNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewMsg:) name:kChatMessageRecvNewMsg object:nil];
    
    m_msgBox = [[ChatMesssageBox alloc] init];
    
    m_msgTb = [[ChatMessageTb alloc] initWithDbQueue:m_dbq];
    if (!m_msgTb) {
        DDLogError(@"ERROR: create `ChatMessageTb` object.");
        return NO;
    }
    return YES;
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kIMAckNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageRecvNewMsg object:nil];
}

- (void)reset {
    [self removeObservers];
}

- (BOOL)sendTextMesage:(NSString *)content
               msgType:(ChatMessageType) msgType
                    to:(NSString *)to
            completion:(void (^)(BOOL finished, id arguments))completion {
    ChatMessage *msg = [[ChatMessage alloc] init];
    msg.from = [m_sid copy];
    msg.to = [to copy];
    msg.time = [[NSDate Now] formatWith:nil];
    msg.chatMsgType = msgType;
    [msg.body setObject:@"text" forKey:@"type"];
    [msg.body setObject:content forKey:@"content"];
    [msg.body setObject:APP_DELEGATE.user.name forKey:@"fromname"];
    if (completion != nil) {
        [m_msgBox putMsgId:msg.qid callback:completion];
    }
    msg.status = ChatMessageStatusSending;
    if (![m_msgTb insertMessage:msg]) {
        DDLogError(@"ERROR: Insert `message` table.");
        return NO;
    }
    [m_session post:msg];

    [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageSendNewMsg object:msg];
    return YES;
}

- (BOOL)sendVoiceMesage:(NSString *)content
                msgType:(ChatMessageType)msgType
                     to:(NSString *)to
             completion:(void (^)(BOOL finished))completion {
    return YES;
}

- (BOOL)sendVideoMesage:(NSString *)content
                msgType:(ChatMessageType)msgType
                     to:(NSString *)to
             completion:(void (^)(BOOL  finished))completion {
    return YES;
}

- (BOOL)sendImageMesage:(NSString *)content
                msgType:(ChatMessageType)msgType
                     to:(NSString *)to
             completion:(void (^)(BOOL finished))completion {
    return YES;
}

- (void)sendImageMesageWithAssets:(NSArray *)assets
                               to:(NSString *)to
                       completion:(void (^)(BOOL finished))completion {
    NSMutableArray *imgPaths = [[NSMutableArray alloc] initWithCapacity:10];
    for (ALAsset *asset in assets) {
        if (asset.defaultRepresentation) {
            UIImage * img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:0.1 orientation:UIImageOrientationUp];
//            NSString *imgName = asset.defaultRepresentation.filename;
            NSString *uuidName = [NSString stringWithFormat:@"%@.jpg", [NSUUID uuid]];
            NSString *imagPath = [APP_DELEGATE.user.filePath stringByAppendingPathComponent:uuidName];
            if (![img saveToPath:imagPath scale:0.1]) {
                completion(NO);
            }
            [imgPaths addObject:imagPath];
        }
    }
}

- (void)sendImageMesageWithAsset:(ALAsset *)asset
                         msgType:(ChatMessageType) msgType
                              to:(NSString *)to
                      completion:(void(^)(BOOL finished, id thumberImgPath))cpt {
    UIImage * img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:0.1 orientation:UIImageOrientationUp];
    __block NSString *uuidName = [NSString stringWithFormat:@"%@.jpg", [NSUUID uuid]];
    NSString *thumbName = [uuidName stringByAppendingString:@"_thumb"];
   __block  NSString *imagPath = [USER.filePath stringByAppendingPathComponent:uuidName];
    __block NSString *imgName = asset.defaultRepresentation.filename;
    if (![img saveToPath:imagPath scale:0.1]) {
        cpt(NO, nil);
        return;
    }
    
    __block NSString *thumbPath = [USER.filePath stringByAppendingPathComponent:thumbName];
    if (![img saveToPath:thumbPath sz:CGSizeMake(210.f, 150.0f)]) {
        cpt(NO, nil);
        [[NSFileManager defaultManager] removeItemAtPath:imagPath error:nil];
        return;
    }
    
    [USER.fileTransfer uploadFileName:uuidName urlString:USER.fileDownloadSvcUrl checkUrlString:USER.fileCheckUrl options:@{@"token":USER.token, @"signature":USER.signature, @"path":imagPath} completion:^(BOOL finished, NSError *error) {
        if (!finished) {
            cpt(NO, error);
        } else {
            ChatMessage *msg = [[ChatMessage alloc] init];
            msg.from = [m_sid copy];
            msg.to = [to copy];
            msg.time = [[NSDate Now] formatWith:nil];
            msg.chatMsgType = msgType;
            [msg.body setObject:@"image" forKey:@"type"];
            [msg.body setObject:uuidName forKey:@"uuid"];
            unsigned long long fileSz = [Utils fileSizeAtPath:imagPath error:nil];
            [msg.body setObject:[NSNumber numberWithUnsignedLongLong:fileSz] forKey:@"filesize"];
            [msg.body setObject:USER.name forKey:@"fromname"];
            [msg.body setObject:imgName forKey:@"filename"];
            
            if (cpt != nil) {
                [m_msgBox putMsgId:msg.qid callback:cpt];
            }
            msg.status = ChatMessageStatusSending;
            if (![m_msgTb insertMessage:msg]) {
                DDLogError(@"ERROR: Insert `message` table.");
                return;
            }
            [m_session post:msg];
            [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageSendNewMsg object:msg];
        }
    }];
}


- (void)sendImageMesageWithImgPath:(NSString *)imagPath
                          uuidName:(NSString *)uuidName
                          imgName:(NSString *)imgName
                           msgType:(ChatMessageType)msgType
                                to:(NSString *)to
                        completion:(void (^)(BOOL finished, id argument))cpt {
    [USER.fileTransfer uploadFileName:uuidName urlString:USER.fileUploadSvcUrl checkUrlString:USER.fileCheckUrl options:@{@"token":USER.token, @"signature":USER.signature, @"path":imagPath} completion:^(BOOL finished, NSError *error) {
        if (!finished) {
            cpt(NO, error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                ChatMessage *msg = [[ChatMessage alloc] init];
                msg.from = [m_sid copy];
                msg.to = [to copy];
                msg.time = [[NSDate Now] formatWith:nil];
                msg.chatMsgType = msgType;
                [msg.body setObject:@"image" forKey:@"type"];
                [msg.body setObject:uuidName forKey:@"uuid"];
                unsigned long long fileSz = [Utils fileSizeAtPath:imagPath error:nil];
                [msg.body setObject:[NSString stringWithFormat:@"%llu", fileSz] forKey:@"filesize"];
                [msg.body setObject:USER.name forKey:@"fromname"];
                [msg.body setObject:imgName forKey:@"filename"];
                
                if (cpt != nil) {
                    [m_msgBox putMsgId:msg.qid callback:cpt];
                }
                msg.status = ChatMessageStatusSending;
                if (![m_msgTb insertMessage:msg]) {
                    DDLogError(@"ERROR: Insert `message` table.");
                    return;
                }
                [m_session post:msg];
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageSendNewMsg object:msg];
            });
        }
    }];
}

- (NSArray *)loadDbMsgsWithId:(NSString *)Id
                         type:(ChatMessageType)msgtype
                        limit:(UInt32)limit
                       offset:(UInt32)offset {
    return [m_msgTb getMsgsWithId:Id msgType:msgtype limit:limit offset:offset];
}

- (void)handleIMMessageAck:(NSNotification *)notification {
    IMAck *ack = notification.object;
    if (ack.ackType == IM_MESSAGE) {
        [m_msgBox notifyMsgId:ack.msgid finished:ack.error ? NO : YES argument:nil];
        DDLogWarn(@"1");
        [m_msgTb updateWithMsgId:ack.msgid status:ack.error ? ChatMessageStatusSendError : ChatMessageStatusSent];
        DDLogWarn(@"2");
    }
}

- (void)handleNewMsg:(NSNotification *)notification {
    ChatMessage *msg = notification.object;
    
    if ([[msg.body objectForKey:@"type"] isEqualToString:@"text"]) {
        if (![m_msgTb insertMessage:msg]) {
            msg.status = ChatMessageStatusRecved;
            DDLogError(@"ERROR: insert msg tbale error in receiving msg.");
        }
    }
    
    if ([[msg.body objectForKey:@"type"] isEqualToString:@"image"]) {
        msg.status = ChatMessageStatusRecving;
        if (![m_msgTb insertMessage:msg]) {
            DDLogError(@"ERROR: insert image msg tbale error in receiving msg.");
        }
        NSString *uuidName = [msg.body objectForKey:@"uuid"];
        __block NSString *imagePath = [USER.filePath stringByAppendingPathComponent:uuidName];
        [USER.fileTransfer downloadFileName:uuidName urlString:USER.fileDownloadSvcUrl checkUrlString:USER.fileCheckUrl options:@{@"token":USER.token, @"signature":USER.signature, @"path":imagePath} completion:^(BOOL finished, NSError *error) {
            if (!finished) {
                DDLogError(@"ERROR: download image file error %@", error);
            } else {
                NSString *thumbPath = [imagePath stringByAppendingString:@"_thumb"];
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                [image saveToPath:thumbPath sz:CGSizeMake(210.0f, 150.0f)];
                [USER.msgMgr updateMsgWithId:msg.qid status:ChatMessageStatusRecved];
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageImageFileReceived object:msg];
            }
        }];
    }
    
    IMAck *ack = [[IMAck alloc] initWithMsgid:msg.qid ackType:msg.type err:nil];
    [m_session post:ack];
}

- (void)updateMsgWithId:(NSString *)msgId status:(ChatMessageStatus)status {
    [m_msgTb updateWithMsgId:msgId status:status];
}

@end
