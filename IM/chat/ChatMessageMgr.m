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
            completion:(void (^)(BOOL finished))completion {
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

- (NSArray *)loadDbMsgsWithId:(NSString *)Id
                         type:(ChatMessageType)msgtype
                        limit:(UInt32)limit
                       offset:(UInt32)offset {
    return [m_msgTb getMsgsWithId:Id msgType:msgtype limit:limit offset:offset];
}

- (void)handleIMMessageAck:(NSNotification *)notification {
    IMAck *ack = notification.object;
    if (ack.ackType == IM_MESSAGE) {
        [m_msgBox notifyMsgId:ack.msgid finished:ack.error ? NO : YES];
        [m_msgTb updateWithMsgId:ack.msgid status:ack.error ? ChatMessageStatusSendError : ChatMessageStatusSent];
    }
}

- (void)handleNewMsg:(NSNotification *)notification {
    ChatMessage *msg = notification.object;
    msg.status = ChatMessageStatusRecved;
    if (![m_msgTb insertMessage:msg]) {
        DDLogError(@"ERROR: insert msg tbale error in receiving msg.");
    }
    IMAck *ack = [[IMAck alloc] initWithMsgid:msg.qid ackType:msg.type err:nil];
    [m_session post:ack];
}


@end
