//
//  OutputStream.m
//  WH
//
//  Created by guozw on 14-10-9.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "OutputStream.h"


#import "NSMutableData+stream.h"
#import "ObjCMongoDB.h"
#import "DataConstants.h"
#import "MessageQueueNode.h"
#import "MessageKeeper.h"
#import "Hb.h"
#import "Pkg.h"
#import "Request.h"
#import "LogLevel.h"

typedef NSMutableArray MessageQueue;
typedef NSMutableData  OSCache;

static const NSUInteger kRunLoopInterval = 1;
static const NSUInteger kCacheCapacity   = 1024;

static const NSUInteger kTimeoutDefault  = 120;

@interface OutputStream() <NSStreamDelegate, MessageKeeperDelegate> {
    NSOutputStream       *m_os;
    OSCache              *m_cache;         // outputStream cache.
    MessageQueue         *m_msgQueue;
    NSThread             *m_ost;           // outputstream thread.
    BOOL                 m_end;
    MessageQueueNode     *m_sendingMsg;
    MessageKeeper        *m_keeper;
    Hb                   *m_hb;
}

// outputstream thread method.
- (void)ost_open;
- (void)ost_close;
- (void)ost_sendMessage:(Request *)msg;
- (void)ost_sendMessage:(Request *)msg timout:(NSUInteger)sec;
- (void)ost_sendHB;
- (void)ost_cancelMessage:(Request *)msg;

@end

@implementation OutputStream

- (instancetype)initWithStream:(NSOutputStream *)outputStream {
    if (self = [super init]) {
        m_os = outputStream;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

#if DEBUG
- (void)dealloc {
    DDLogInfo(@"%@ dealloc", NSStringFromClass([self class]));
}
#endif

- (BOOL)setup {
    m_ost = [[NSThread alloc]initWithTarget:self selector:@selector(run) object:nil];
    [m_ost start];
    m_msgQueue = [[NSMutableArray alloc]init];
    return YES;
}

- (void)open {
    [self performSelector:@selector(ost_open) onThread:m_ost withObject:nil waitUntilDone:NO];
}

- (void)close {
    [self performSelector:@selector(ost_close) onThread:m_ost withObject:nil waitUntilDone:NO];
}

- (void)cancel:(Message *)message {
    [self performSelector:@selector(ost_cancelMessage:) onThread:m_ost withObject:message waitUntilDone:NO];
}

- (BOOL)opened {
    if (m_os.streamStatus == NSStreamStatusOpen || m_os.streamStatus == NSStreamStatusWriting) {
        return YES;
    }
    return NO;
}

- (void)sendWithMessage:(Message *)msg timeout:(NSUInteger)sec {
    NSNumber *num = [[NSNumber alloc]initWithUnsignedLong:sec];
    [self performSelector:@selector(ost_sendMessageWithParams:) onThread:m_ost withObject:@[msg, num] waitUntilDone:NO];
}

- (void)sendWithMessage:(Message *)msg {
    [self performSelector:@selector(ost_sendMessage:) onThread:m_ost withObject:nil waitUntilDone:NO];
}

- (void)sendHB {
    if ([[NSThread currentThread] isEqual:m_ost]) {
        [self ost_sendHB];
    } else {
        [self performSelector:@selector(ost_sendHB) onThread:m_ost withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - outputstream thread mothod.

- (void)ost_open {
    m_cache = [[NSMutableData alloc]initWithCapacity:kCacheCapacity];
    [m_os scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    m_os.delegate = self;
    [m_os open];
}

- (void)ost_close {
    DDLogInfo(@"close the outputstream.");
    [self stop];
    m_end = YES;
}

- (void)ost_sendMessage:(Request *)msg {
    [self ost_sendMessage:msg timout:kMessageSendInfinite];
}

- (void)ost_sendMessage:(Request *)msg timout:(NSUInteger)sec {
    MessageQueueNode *mqn = [[MessageQueueNode alloc]initWithMessage:msg timeout:sec];
    [m_msgQueue addObject:mqn];
    [self sendMessageIfAvailable];
    
}

- (void)ost_sendMessageWithParams:(NSArray *)params {
    Request *msg = [params objectAtIndex:0];
    NSNumber *timeout = [params objectAtIndex:1];
    [self ost_sendMessage:msg timout:timeout.unsignedIntValue];
}

- (void)ost_sendHB {
    MessageQueueNode *hbMqn = [[MessageQueueNode alloc]initWithMessage:nil timeout:kTimeoutDefault];
    hbMqn.hb = YES;
    [m_msgQueue addObject:hbMqn];
    [self sendMessageIfAvailable];
}

- (void)ost_cancelMessage:(Message *)msg {
    for (MessageQueueNode *node in m_msgQueue) {
        if ([node.msg isEqual:msg]) {
            [m_msgQueue removeObject:node];
            break;
        }
    }
    if ([self.delegate respondsToSelector:@selector(OutputStream:cancel:msg:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate OutputStream:self cancel:YES msg:msg];
        });
    }
}

- (void)sendMessageIfAvailable {
    if (m_os.hasSpaceAvailable) {
        if (m_cache.length > 0) {
            [m_hb resetStick];
            NSInteger sent = [m_os write:[m_cache bytes] maxLength:m_cache.length];
            [m_cache popLen:sent];
            if (m_cache.length == 0 && [m_sendingMsg isEqual:[m_msgQueue objectAtIndex:0]]) {
                [m_msgQueue removeObjectAtIndex:0];
                [self tellDelegateMsg:m_sendingMsg.msg sent:YES error:nil];
            }
        } else {
            if (m_msgQueue.count > 0) {
                m_sendingMsg = [m_msgQueue objectAtIndex:0];
                [self appendToCache];
                if (m_cache.length > 0) {
                    [m_hb resetStick];
                    NSInteger sent = [m_os write:[m_cache bytes] maxLength:m_cache.length];
                    [m_cache popLen:sent];
                    if (m_cache.length == 0 && [m_sendingMsg isEqual:[m_msgQueue objectAtIndex:0]]) {
                        [m_msgQueue removeObjectAtIndex:0];
                        [self tellDelegateMsg:m_sendingMsg.msg sent:YES error:nil];
                    }
                }
               
            }
        }
    }
}

#pragma mark -private method.

- (void)tellDelegateMsg:(Message *)message sent:(BOOL)sent error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(OutputStream:message:sent:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(OutputStream:message:sent:error:)]) {
                [self.delegate OutputStream:self message:message sent:sent error:error];
            }
        });
    }
}

- (NSError *)msgErrorTimeout {
    NSError *error = [[NSError alloc]initWithDomain:@"OutputStream" code:OutputStreamMsgErrorTimeout userInfo:@{@"errorDescription" : @"the message is timeout!"}];
    return error;
}

- (NSError *)msgErrorStreamWrong {
    NSError *error = [[NSError alloc]initWithDomain:@"OutputStream" code:OutputStreamMsgErrorStreamWrong userInfo:@{@"errorDescription" : @"the inputstream is wrong!"}];
    return error;
}

- (NSError *)msgErrorStreamClose {
    NSError *error = [[NSError alloc]initWithDomain:@"OutputStream" code:OutputStreamMsgErrorStreamClosed userInfo:@{@"errorDescription" : @"the inputstream is closed!"}];
    return error;
}

- (void)start {
    m_keeper = [[MessageKeeper alloc]initWithMessageQueue:m_msgQueue];
    [m_keeper start];
    m_keeper.delegate = self;
    m_hb = [[Hb alloc]initWithOutputStream:self];
    [m_hb start];
}

- (void)stop {
    [m_keeper stop];
    m_keeper = nil;
    [m_hb stop];
    m_hb = nil;
}

- (void)appendToCache {
    if (!m_sendingMsg.hb) {
        if (m_sendingMsg.msg.msgType == MessageTypeRequest) {
            Request *req = (Request *)m_sendingMsg.msg;
            NSData *data = [req pkgData];
            UInt32 type = htonl(req.type);
            UInt32 dataLen = htonl(sizeof(type) + (UInt32)data.length);
            [m_cache appendBytes:&dataLen length:sizeof(UInt32)];
            [m_cache appendBytes:&type length:sizeof(UInt32)];
//            DDLogInfo(@"msg type:%x", m_sendingMsg.msg.type);
            if (data) {
                [m_cache appendData:data];
            }
        }
    } else {
        UInt32 hb = 0;
        [m_cache appendBytes:&hb length:sizeof(UInt32)];
        DDLogInfo(@"--> HeartBeat");
    }
    
    
}

#pragma mark -NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            DDLogVerbose(@"NStreamEventNone");
            break;
        case NSStreamEventOpenCompleted:
            DDLogVerbose(@"OpenCompleted in OutputStream!");
            [self start];
            if ([self.delegate respondsToSelector:@selector(OutputStream:openCompletion:)]) {
                [self.delegate OutputStream:self openCompletion:YES];
            }
            break;
        case NSStreamEventEndEncountered:
            [self stop];
            for (MessageQueueNode *node in m_msgQueue) {
                [self tellDelegateMsg:node.msg sent:NO error:[self msgErrorStreamClose]];
            }
            if ([self.delegate respondsToSelector:@selector(OutputStream:closed:)]) {
                [self.delegate OutputStream:self closed:YES];
            }
            DDLogInfo(@"NSStreamEventEndEncountered in OutputStream!");
            m_end = YES;
            break;
        case NSStreamEventErrorOccurred:
            DDLogError(@"An error has occurred on the output stream:%@", aStream.streamError);
            [self stop];
            for (MessageQueueNode *node in m_msgQueue) {
                [self tellDelegateMsg:node.msg sent:NO error:[self msgErrorStreamWrong]];
            }
            if ([self.delegate respondsToSelector:@selector(OutputStream:error:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate OutputStream:self error:aStream.streamError];
                });
            }
            m_end = YES;
            break;
        case NSStreamEventHasBytesAvailable:
        {
            DDLogVerbose(@"oh what a fuck cybertech in OutputStream!");
        }
            break;
        case NSStreamEventHasSpaceAvailable:
        {
            DDLogVerbose(@"NSStreamEventHasSpaceAvailable in OutputStream.");
            [self sendMessageIfAvailable];
        }
            break;
        default:
            break;
    }
}

#pragma mark -thread entry

- (void)run {
    do {
        @autoreleasepool {
            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:kRunLoopInterval]];
        }
        
    } while (!m_end);
    [m_os close];
    DDLogInfo(@"outputstream thread will exit.");
}

#pragma mark -MessageKeeper delegate

- (void)MessageKeeper:(MessageKeeper *)keeper timeoutMessage:(Message *) message {
    if ([self.delegate respondsToSelector:@selector(OutputStream:message:timeout:)]) {
        [self.delegate OutputStream:self message:message timeout:YES];
    }
}

@end
