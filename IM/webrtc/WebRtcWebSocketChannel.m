//
//  WebRtcWebSocketChannel.m
//  IM
//
//  Created by 郭志伟 on 15-3-25.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "WebRtcWebSocketChannel.h"
#import "WebrtcSRWebSocket.h"
#import "LogLevel.h"


@interface WebRtcWebSocketChannel() <WebrtcSRWebSocketDelegate>
@end

@implementation WebRtcWebSocketChannel {
    WebrtcSRWebSocket *_socket;
    NSURL       *_url;
    NSMutableDictionary *_msgQueue;
    void (^_connectCallback)(BOOL ok);
    NSTimer *_pingTimer;
}


- (void)dealloc {
    DDLogInfo(@"WebRtcWebSocketChannel dealloc");
    if (_pingTimer) {
        [_pingTimer invalidate];
        _pingTimer = nil;
    }
    _socket.delegate = nil;
}

- (instancetype)initWithUrl:(NSURL *)url
                   delegate:(id<WebRtcWebSocketChannelDelegate>)delegate{
    if (self = [super init]) {
        _url = url;
        _delegate = delegate;
        _msgQueue = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)connectWithCompletion:(void(^)(BOOL ok))completion {
    _socket = [[WebrtcSRWebSocket alloc] initWithURL:_url];
    _socket.delegate = self;
    _connectCallback = completion;
    [_socket open];
}

- (void)disconnect {
    if (_state == kWebRtcWebSocketChannelStateClosed ||
        _state == kWebRtcWebSocketChannelStateError) {
        return;
    }
    
    [_socket close];
    _socket = nil;
}


- (void)setState:(WebRtcWebSocketChannelState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    [_delegate channel:self didChangeState:_state];
}

- (void)sendData:(NSData *)data {
    [_socket send:data];
}

//- (void)sendMessage:(WebRtcSignalingMessage *)msg
//                ack:(void(^)(WebRtcAckMessage *ackMsg)) ack {
//    [_msgQueue setObject:ack forKey:msg.msgId];
//    [_socket send:msg.JSONData];
//}

#pragma mark -SRWebSocketDelegate

- (void)webSocket:(WebrtcSRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSString *messageString = message;
    DDLogInfo(@"INFO:<-- %@", message);
    WebRtcSignalingMessage *m = [WebRtcSignalingMessage messageFromJSONString:messageString];
    if (!m) {
        DDLogWarn(@"WARN: unkown message.");
        return;
    }
    [_delegate channel:self didReceiveMessage:m];
    if ([m isKindOfClass:[WebRtcSeqMessage class]]) {
        if (_connectCallback) {
            _connectCallback(YES);
            _connectCallback = nil;
        }
    }
}

- (void)webSocketDidOpen:(WebrtcSRWebSocket *)webSocket {
     self.state = kWebRtcWebSocketChannelStateOpen;
    _pingTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(ping) userInfo:nil repeats:YES];
}

- (void)ping {
    BOOL ret = [_socket sendPing];
    if (!ret) {
        [_pingTimer invalidate];
        _pingTimer = nil;
    }
}

- (void)webSocket:(WebrtcSRWebSocket *)webSocket didFailWithError:(NSError *)error {
    DDLogInfo(@"WebSocket error: %@", error);
    self.state = kWebRtcWebSocketChannelStateError;
    if (_pingTimer) {
        [_pingTimer invalidate];
        _pingTimer = nil;
    }
    if (_connectCallback) {
        _connectCallback(NO);
        _connectCallback = nil;
    }
}

- (void)webSocket:(WebrtcSRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    DDLogInfo(@"WebSocket closed with code: %ld reason:%@ wasClean:%d",
          (long)code, reason, wasClean);
    if (_pingTimer) {
        [_pingTimer invalidate];
        _pingTimer = nil;
    }
    if (_connectCallback) {
        _connectCallback(NO);
        _connectCallback = nil;
    }
        
    NSParameterAssert(_state != kWebRtcWebSocketChannelStateError);
    self.state = kWebRtcWebSocketChannelStateClosed;
}

@end
