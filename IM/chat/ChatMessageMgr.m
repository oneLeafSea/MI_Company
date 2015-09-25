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
#import "RTSystemSoundPlayer+RTMessages.h"
#import "RTFileTransfer.h"
#import "session.h"
#import "LoginNotification.h"



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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionFailed:) name:kSessionConnectedFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginSucess:) name:kNotificationLoginSuccess object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSessionConnectedFail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLoginSuccess object:nil];
}

- (void)dealloc {
    [self removeObservers];
}


- (void)reset {
    [self removeObservers];
}

- (BOOL)sendTextMesage:(NSString *)content
               msgType:(ChatMessageType) msgType
                    to:(NSString *)to
            completion:(void (^)(BOOL finished, id arguments))completion {
    ChatMessage *msg = [[ChatMessage alloc] init];
    NSString *txtContent = [Utils encodeBase64String:content];
    msg.from = [m_sid copy];
    msg.to = [to copy];
    msg.time = [[NSDate Now] formatWith:nil];
    msg.chatMsgType = msgType;
    [msg.body setObject:@"text" forKey:@"type"];
    [msg.body setObject:txtContent forKey:@"content"];
    [msg.body setObject:APP_DELEGATE.user.name forKey:@"fromname"];
    [msg.body setObject:@YES forKey:@"b64"];
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

- (BOOL)sendVoiceMesageWithMsgType:(ChatMessageType)msgType
                     to:(NSString *)to
               duration:(NSInteger)duration
              audioPath:(NSString *)audioPath
             completion:(void (^)(BOOL finished, id arguments))completion {
    
    [RTFileTransfer uploadFileWithServerUrl:USER.fileUploadSvcUrl2 filePath:audioPath token:USER.token key:USER.key iv:USER.iv progress:nil completion:^(BOOL finished) {
        if (finished) {
            ChatMessage *msg = [[ChatMessage alloc] init];
            msg.from = [m_sid copy];
            msg.to = [to copy];
            msg.time = [[NSDate Now] formatWith:nil];
            msg.chatMsgType = msgType;
            [msg.body setObject:@"voice" forKey:@"type"];
            [msg.body setObject:APP_DELEGATE.user.name forKey:@"fromname"];
            [msg.body setObject:[audioPath lastPathComponent] forKey:@"uuid"];
            [msg.body setObject:[NSString stringWithFormat:@"%ld", (long)duration] forKey:@"duration"];
            [msg.body setObject:[audioPath lastPathComponent] forKey:@"filename"];
            unsigned long long filesz = [Utils fileSizeAtPath:audioPath error:nil];
            [msg.body setObject:[NSString stringWithFormat:@"%llu", filesz] forKey:@"filesize"];
            
            if (completion != nil) {
                [m_msgBox putMsgId:msg.qid callback:completion];
            }
            
            msg.status = ChatMessageStatusSending;
            if (![m_msgTb insertMessage:msg]) {
                DDLogError(@"ERROR: Insert voice `message` table.");
            }
            [m_session post:msg];
            [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageSendNewMsg object:msg];
        }
    }];
    return YES;
}

- (void)sendFileMessageWithFilePath:(NSString *)filePath
                             msgType:(ChatMessageType)msgType
                                  to:(NSString *)to
                          completion:(void (^)(BOOL finished, id argument))completion {
    [RTFileTransfer uploadFileWithServerUrl:USER.fileUploadSvcUrl2 filePath:filePath token:USER.token key:USER.key iv:USER.iv progress:nil completion:^(BOOL finished) {
        if (finished) {
            ChatMessage *msg = [[ChatMessage alloc] init];
            msg.from = [m_sid copy];
            msg.to = [to copy];
            msg.time = [[NSDate Now] formatWith:nil];
            msg.chatMsgType = msgType;
            [msg.body setObject:@"file" forKey:@"type"];
            [msg.body setObject:APP_DELEGATE.user.name forKey:@"fromname"];
            [msg.body setObject:[filePath lastPathComponent] forKey:@"uuid"];
            [msg.body setObject:[filePath lastPathComponent] forKey:@"filename"];
            unsigned long long filesz = [Utils fileSizeAtPath:filePath error:nil];
            [msg.body setObject:[NSString stringWithFormat:@"%llu", filesz] forKey:@"filesize"];
            
            if (completion != nil) {
                [m_msgBox putMsgId:msg.qid callback:completion];
            }
            
            msg.status = ChatMessageStatusSending;
            if (![m_msgTb insertMessage:msg]) {
                DDLogError(@"ERROR: Insert file `message` table.");
            }
            [m_session post:msg];
            [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageSendNewMsg object:msg];
        }
    }];
}


- (void)InsertVideoChatWithFrom:(NSString *)from
                       fromName:(NSString *)fromName
                             to:(NSString *)to
                          msgId:(NSString *)msgId
                      connected:(BOOL)connected
                       interval:(NSUInteger)interval {
    ChatMessage *msg = [[ChatMessage alloc] init];
    msg.qid = msgId;
    msg.from = from;
    msg.to = to;
    msg.time = [[NSDate Now] formatWith:nil];
    msg.chatMsgType = ChatMessageTypeNormal;
    [msg.body setObject:@"videochat" forKey:@"type"];
    [msg.body setObject:[NSNumber numberWithBool:connected] forKey:@"connected"];
    [msg.body setObject:[NSNumber numberWithInteger:interval] forKey:@"interval"];
    [msg.body setObject:fromName forKey:@"fromname"];
    if ([m_msgTb insertMessage:msg]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageVideoChatMsg object:msg];
    }
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
    UIImage * img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:1.0 orientation:UIImageOrientationUp];
    __block NSString *uuidName = [NSString stringWithFormat:@"%@.jpg", [NSUUID uuid]];
    NSString *thumbName = [uuidName stringByAppendingString:@"_thumb"];
   __block  NSString *imagPath = [USER.filePath stringByAppendingPathComponent:uuidName];
    __block NSString *imgName = asset.defaultRepresentation.filename;
    if (![img saveToPath:imagPath scale:1.0]) {
        cpt(NO, nil);
        return;
    }
    
    __block NSString *thumbPath = [USER.filePath stringByAppendingPathComponent:thumbName];
    if (![img saveToPath:thumbPath sz:CGSizeMake(100.0f, 100.0f)]) {
        cpt(NO, nil);
        [[NSFileManager defaultManager] removeItemAtPath:imagPath error:nil];
        return;
    }
    
    [RTFileTransfer uploadFileWithServerUrl:USER.fileUploadSvcUrl2 filePath:imagPath token:USER.token key:USER.key iv:USER.iv progress:nil completion:^(BOOL finished) {
        if (!finished) {
            cpt(NO, nil);
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
    
    [RTFileTransfer uploadFileWithServerUrl:USER.fileUploadSvcUrl2 filePath:imagPath token:USER.token key:USER.key iv:USER.iv progress:nil completion:^(BOOL finished) {
        if (!finished) {
            cpt(NO, nil);
        } else {
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
        if ([m_msgTb updateWithMsgId:ack.msgid status:ack.error ? ChatMessageStatusSendError : ChatMessageStatusSent]) {
            [m_msgTb updateWithMsgId:ack.msgid time:ack.time];
        }
        [m_msgBox notifyMsgId:ack.msgid finished:ack.error ? NO : YES argument:nil];
        
    }
}

- (void)handleSessionFailed:(NSNotification *)notification {
    [m_msgTb updateSendingMsgToFail];
}

- (void)handleLoginSucess:(NSNotification *)notification {
    [m_msgTb updateSendingMsgToFail];
}

- (void)scheduleNotificationWithinterval:(int)minutesBefore {
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    //    [dateComps setDay:item.day];
    //    [dateComps setMonth:item.month];
    //    [dateComps setYear:item.year];
    //    [dateComps setHour:item.hour];
    //    [dateComps setMinute:item.minute];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = itemDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"%@ in %i minutes.", nil),
                            @"ceshi", minutesBefore];
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    localNotif.alertTitle = NSLocalizedString(@"Item Due", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"测试" forKey:@"title"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)showNotificationWithTitle:(NSString *)title body:(NSString *)body {
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = itemDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = body;
    localNotif.alertAction = @"查看消息";
    
    localNotif.soundName = @"msn.aiff";
    localNotif.applicationIconBadgeNumber++;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)handleNewMsg:(NSNotification *)notification {
    __block ChatMessage *msg = notification.object;
    
   
    
    if ([[msg.body objectForKey:@"type"] isEqualToString:@"text"]) {
        if (![m_msgTb insertMessage:msg]) {
            msg.status = ChatMessageStatusRecved;
            DDLogError(@"ERROR: insert msg tbale error in receiving msg.");
            IMAck *ack = [[IMAck alloc] initWithMsgid:msg.qid ackType:msg.type time:[NSDate stringNow] err:nil];
            [m_session post:ack];
            return;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                __block NSString *content = [msg.body objectForKey:@"content"];
                NSNumber *b64 = [msg.body objectForKey:@"b64"];
                if ([b64 boolValue]) {
                    content = [Utils decodeBase64String:content];
                }
                NSString *name = [msg.body objectForKey:@"fromname"];
                [self showNotificationWithTitle:@"文本消息" body:[NSString stringWithFormat:@"%@:%@", name, content]];
            });
        }
    }
    
    if ([[msg.body objectForKey:@"type"] isEqualToString:@"image"]) {
        msg.status = ChatMessageStatusRecved;
        __block NSString *uuidName = [msg.body objectForKey:@"uuid"];
        if (!uuidName) {
            DDLogError(@"ERROR: uuidName is nil");
            return;
        }
        if (![m_msgTb insertMessage:msg]) {
            DDLogError(@"ERROR: insert image msg tbale error in receiving msg.");
            IMAck *ack = [[IMAck alloc] initWithMsgid:msg.qid ackType:msg.type time:[NSDate stringNow] err:nil];
            [m_session post:ack];
            return;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                 NSString *name = [msg.body objectForKey:@"fromname"];
                [self showNotificationWithTitle:@"图像" body:[NSString stringWithFormat:@"%@:[图片]", name]];
            });
        }
    }
    
    if ([[msg.body objectForKey:@"type"] isEqualToString:@"voice"]) {
        msg.status = ChatMessageStatusRecving;
        if (![m_msgTb insertMessage:msg]) {
            DDLogError(@"ERROR: insert voice msg table.");
            IMAck *ack = [[IMAck alloc] initWithMsgid:msg.qid ackType:msg.type time:[NSDate stringNow] err:nil];
            [m_session post:ack];
            return;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *name = [msg.body objectForKey:@"fromname"];
                [self showNotificationWithTitle:@"音频" body:[NSString stringWithFormat:@"%@:[音频]", name]];
            });
        }
        NSString *uuidName = [msg.body objectForKey:@"uuid"];
        [RTFileTransfer downFileWithServerUrl:USER.fileDownloadSvcUrl fileDir:USER.audioPath fileName:uuidName token:USER.token key:USER.key iv:USER.iv progress:^(double progress) {
            
        } completion:^(BOOL finished) {
            if (!finished) {
                DDLogError(@"ERROR: download audio file error");
            } else {
                [USER.msgMgr updateMsgWithId:msg.qid status:ChatMessageStatusRecved];
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageImageFileReceived object:msg];
            }
        }];
    }
    
    if ([[msg.body objectForKey:@"type"] isEqualToString:@"file"]) {
        msg.status = ChatMessageStatusRecving;
        if (![m_msgTb insertMessage:msg]) {
            DDLogError(@"ERROR: insert file msg table.");
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground) {
            return;
        }
        if ([msg.from isEqualToString:USER.uid]) {
            return;
        }
        [RTSystemSoundPlayer rt_playMessageReceivedSound];
        [[RTSystemSoundPlayer sharedPlayer] playVibrateSound];
    });
    IMAck *ack = [[IMAck alloc] initWithMsgid:msg.qid ackType:msg.type time:[NSDate stringNow] err:nil];
    [m_session post:ack];
}

- (void)updateMsgWithId:(NSString *)msgId status:(ChatMessageStatus)status {
    [m_msgTb updateWithMsgId:msgId status:status];
}

- (ChatMessage *)getLastGrpChatMsgWithGid:(NSString *)gid {
    return [m_msgTb getLastGrpChatMsgByGid:gid];
}

- (ChatMessage *)getMsgByMsgId:(NSString *)msgId {
    return [m_msgTb getMsgByMsgId:msgId];
}

- (BOOL) insertMsg:(ChatMessage *)msg {
    return [m_msgTb insertMessage:msg];
}

@end
