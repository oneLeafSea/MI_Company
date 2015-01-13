//
//  session.m
//  WH
//
//  Created by rooten-mac on 14-10-9.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Session.h"


#import "InputStream.h"
#import "OutputStream.h"
#import "LogLevel.h"
#import "Response.h"
#import "MessageConstants.h"
#import "ServerTimeMsg.h"


NSString *kSessionConnected = @"cn.com.rooten.net.session.connected";
NSString *kSessionDied = @"cn.com.rooten.net.session.died";
NSString *kSessionTimeout = @"cn.com.rooten.net.session.timeout";
NSString *kSessionServerTime = @"cn.com.rooten.net.sesion.servertime";

typedef NSMutableDictionary RequestMap;


@interface Session() <InputStreamDelegate, OutputStreamDelegate> {
    InputStream     *m_is;
    OutputStream    *m_os;
    BOOL            m_end;
    NSString        *m_IP;
    UInt32          m_port;
    BOOL            m_tls;
    BOOL            m_connected;
    RequestMap      *m_requestMap;
    
    NSTimer         *m_timerout;
}
@end

@implementation Session


- (instancetype)init {
    if (self = [super init]) {
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (void)dealloc {
    DDLogInfo(@"%@ dealloc", NSStringFromClass([self class]));
    [m_is close];
    [m_os close];
}

- (BOOL)setup {
    BOOL ret = YES;
    m_connected = NO;
    m_requestMap = [[NSMutableDictionary alloc]initWithCapacity:128];
    return ret;
}

- (BOOL)connectToIP:(NSString *)IP port:(UInt32)port TLS:(BOOL)tls {
    [self connectToIP:IP port:port TLS:tls timeout:0];
    return YES;
}

- (BOOL)connectToIP:(NSString *)IP port:(UInt32)port TLS:(BOOL)tls timeout:(NSTimeInterval) timeout {
    
    m_IP = IP;
    m_port = port;
    m_tls = tls;
    if (timeout > 0) {
        m_timerout = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(connectTimeout) userInfo:nil repeats:NO];
    }
    [self connect];
    return YES;
}

- (void)connectTimeout {
    [m_timerout invalidate];
    if ([self.delegate respondsToSelector:@selector(session:connected:timeout:error:)]) {
        [self.delegate session:self connected:NO timeout:YES error:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionTimeout object:self];
}

- (void)connect {
    CFReadStreamRef rs;
    CFWriteStreamRef ws;
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)m_IP, m_port, &rs, &ws);
    NSInputStream *input = (__bridge NSInputStream*)rs;
    NSOutputStream *ouput = (__bridge NSOutputStream*)ws;
    
    if (m_tls) {
        [input setProperty:NSStreamSocketSecurityLevelTLSv1 forKey:NSStreamSocketSecurityLevelKey];
        [ouput setProperty:NSStreamSocketSecurityLevelTLSv1 forKey:NSStreamSocketSecurityLevelKey];
        NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain,
                                  NSStreamSocketSecurityLevelTLSv1, kCFStreamSSLLevel,
                                  kCFBooleanFalse, kCFStreamSSLIsServer,
                                  nil];
        
        if (rs) {
            CFReadStreamSetProperty(rs, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
        }
        
        if (ws) {
            CFWriteStreamSetProperty(ws, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
        }
    }
    
    m_os = [[OutputStream alloc]initWithStream:ouput];
    m_is = [[InputStream alloc]initWithStream:input];
    m_os.delegate = self;
    m_is.delegate = self;
    [m_is open];
    [m_os open];
}

- (void)disconnect {
    [m_is close];
    [m_os close];
}

- (void)request:(Request *)req {
    if (req.qid == nil) {
        DDLogWarn(@"the request qid is nil!");
        return;
    }
    [m_requestMap setValue:req forKey:req.qid];
    [self sendMessage:req];
}

- (void)post:(Request *)req {
    [self sendMessage:req];
}

- (void)cancelRequest:(Request *)req {
    [m_requestMap removeObjectForKey:req.qid];
}



- (void)sendMessage:(Request *)msg {
    [m_os sendWithMessage:msg timeout:30];
}


#pragma -mark InputStreamDelegate
- (void)InputStream:(InputStream *)inputStream openCompletion:(BOOL)completion {
    [self tellDelegateOpened:completion];
}

- (void)InputStream:(InputStream *)inputStream closed:(BOOL)close {
    [m_os close];
    if ([self.delegate respondsToSelector:@selector(sessionDied:error:)]) {
        [self.delegate sessionDied:self error:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionDied object:self];
}

- (void)InputStream:(InputStream *)inputStream newMessage:(Message *)newMsg {
    switch (newMsg.msgType) {
        case MessageTypeMessage:
        {
            if (newMsg.type == MSG_SVR_TIME) {
                ServerTimeMsg * timeMsg = (ServerTimeMsg *)newMsg;
                if ([self.delegate respondsToSelector:@selector(session:serverTime:)]) {
                    [self.delegate session:self serverTime:[timeMsg.svrTime copy]];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kSessionServerTime object:[timeMsg.svrTime copy]];
            }
        }
            break;
        case MessageTypeResponse:
        {
            Response *resp = (Response *)newMsg;
            Request *req = [m_requestMap objectForKey:resp.qid];
            if (req && [req.delegate respondsToSelector:@selector(request:response:)]) {
                [req.delegate request:req response:resp];
                [m_requestMap removeObjectForKey:req.qid];
            }
        }
            break;
        case MessageTypePush:
            break;
        default:
            break;
    }
}

- (void)InputStream:(InputStream *)inputStream error:(NSError *)err {
    
    if (err.code == 61) {
        [m_timerout invalidate];
        if ([self.delegate respondsToSelector:@selector(session:connected:timeout:error:)]) {
            [self.delegate session:self connected:NO timeout:NO error:err];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kSessionTimeout object:self];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(sessionDied:error:)]) {
        [self.delegate sessionDied:self error:err];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionDied object:self];
    
}


- (void)tellDelegateOpened:(BOOL)completion {
    if (completion) {
        if (m_is.opened && m_os.opened) {
            if (!m_connected) {
                m_connected = YES;
                if ([self.delegate respondsToSelector:@selector(session:connected:timeout:error:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [m_timerout invalidate];
                        [self.delegate session:self connected:YES timeout:NO error:nil];
                       
                    });
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kSessionConnected object:self];
            }
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(session:connected:timeout:error:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_timerout invalidate];
                [self.delegate session:self connected:NO timeout:NO error:nil];
            });
        }
    }
}


#pragma -mark OutputStreamDelegate
- (void)OutputStream:(OutputStream *)outputStream openCompletion:(BOOL)completion {
    [self tellDelegateOpened:completion];
}

- (void)OutputStream:(OutputStream *)outputStream closed:(BOOL)closed {

    [m_is close];
    if ([self.delegate respondsToSelector:@selector(sessionDied:error:)]) {
        [self.delegate sessionDied:self error:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionDied object:self];
}

- (void)OutputStream:(OutputStream *)outputStream error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(sessionDied:error:)]) {
        [self.delegate sessionDied:self error:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionDied object:self];
}

- (void)OutputStream:(OutputStream *)outputStream message:(Message *)message sent:(BOOL)sent error:(NSError *)error {
    if (sent) {
        return;
    }
    switch (message.msgType) {
        case MessageTypeRequest:
        {
            Request *req = (Request *)message;
            if (req && [req.delegate respondsToSelector:@selector(request:error:)]) {
                [req.delegate request:req error:error];
            }
            [m_requestMap removeObjectForKey:req.qid];
        }
            break;
        default:
            break;
    }
}

- (void)OutputStream:(OutputStream *)outputStream cancel:(BOOL)cancelled msg:(Message *)msg {
    
}

- (void)OutputStream:(OutputStream *)outputStream message:(Message *)message timeout:(BOOL)timeout {
    DDLogWarn(@"Message is timeout!");
}
@end
