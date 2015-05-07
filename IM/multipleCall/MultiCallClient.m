//
//  MultiCallClient.m
//  IM
//
//  Created by 郭志伟 on 15/5/4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "MultiCallClient.h"

#import "WebRtcWebSocketChannel.h"
#import "RTCAudioTrack.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCMediaStream.h"
#import "RTCICEServer.h"
#import "Encrypt.h"
#import "NSUUID+StringUUID.h"
#import "MultiCallPeerConnection.h"
#import "LogLevel.h"
#import "WebRtcNotifyMsg.h"

@interface MultiCallClient() <WebRtcWebSocketChannelDelegate, MultiCallPeerConnectionDelegate> {
    WebRtcWebSocketChannel *_chanel;
    NSString               *_seq;
    NSMutableDictionary    *_peerConnections;
}
@property(nonatomic, strong) RTCPeerConnectionFactory *factory;
@property(nonatomic, strong) RTCMediaStream *localStream;
@property(nonatomic, strong) NSMutableArray *iceServers;

@end

@implementation MultiCallClient

- (instancetype)initWithDelegate:(id<MultiCallClientDelegate>)delegate
                      roomServer:(NSURL *)url
                          iceUrl:(NSString *)iceUrl
                           token:(NSString *)token
                             key:(NSString *)key
                              iv:(NSString *)iv
                             uid:(NSString *)uid
                         invited:(BOOL)invited {
    if (self = [super init]) {
        _serverHost = url;
        _iceUrl = iceUrl;
        _uid = uid;
        _delegate = delegate;
        _factory = [[RTCPeerConnectionFactory alloc] init];
        _iceServers = [NSMutableArray arrayWithObjects:[self defaultSTUNServer], [self defaultTurnServer], nil];
        _invited = invited;
        _token = token;
        _iv = iv;
        _key = key;
        _peerConnections = [[NSMutableDictionary alloc] init];
        _localStream = [self createLocalMediaStream];
    }
    return self;
}

- (void)createRoomId:(NSString *)roomId
             session:(Session *)session
         talkingUids:(NSArray *)talkingUids {
    _chanel = [[WebRtcWebSocketChannel alloc] initWithUrl:_serverHost delegate:self];
    [_chanel connectWithCompletion:^(BOOL ok) {
        if (ok) {
            WebRtcCreateRoomMessage *m = [[WebRtcCreateRoomMessage alloc] initWithFrom:_uid
                                                                               fromRes:@"iphone"
                                                                                    to:@""
                                                                                 toRes:@""
                                                                                 msgId:[NSUUID uuid]
                                                                                 topic:@"create"
                                                                               content:nil];
            m.seq = [NSString stringWithFormat:@"%@%@", _seq, [NSUUID uuid]];
            m.seq = [Encrypt encodeWithKey:self.key iv:self.iv data:[m.seq dataUsingEncoding:NSUTF8StringEncoding] error:nil];
            m.token = self.token;
            _roomId = roomId;
            [m setRoomId:_roomId uid:_uid];
            [_chanel sendData:m.JSONData];
            _state = kMultiCallClientStateeConnected;
            [talkingUids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WebRtcNotifyMsg *notifyMsg = [[WebRtcNotifyMsg alloc] initWithFrom:_uid to:obj rid:_roomId];
                notifyMsg.contentType = @"mulitivoice";
                [session post:notifyMsg];
            }];
        }
    }];
}

- (void)joinRoomId:(NSString *)rid {
    _chanel = [[WebRtcWebSocketChannel alloc] initWithUrl:_serverHost delegate:self];
    [_chanel connectWithCompletion:^(BOOL ok) {
        if (ok) {
            self.state = kMultiCallClientStateeConnected;
            WebRtcJoinRoomMessage *m = [[WebRtcJoinRoomMessage alloc] initWithFrom:_uid
                                                                           fromRes:@"iphone"
                                                                                to:@""
                                                                             toRes:@""
                                                                             msgId:[NSUUID uuid]
                                                                             topic:@"join"
                                                                           content:nil];
            
            m.seq = [NSString stringWithFormat:@"%@%@", _seq, [NSUUID uuid]];
            m.seq = [Encrypt encodeWithKey:self.key iv:self.iv data:[m.seq dataUsingEncoding:NSUTF8StringEncoding] error:nil];
            m.token = self.token;
            [m setRid:rid];
            [_chanel sendData:[m JSONData]];
        }
    }];
}

- (void)mute {
    RTCMediaStream *localStream = _localStream;
    RTCAudioTrack *audioTrack = localStream.audioTracks[0];
    [audioTrack setEnabled:![audioTrack isEnabled]];
}

- (BOOL)isMute {
    RTCMediaStream *localStream = _localStream;
    RTCAudioTrack *audioTrack = localStream.audioTracks[0];
    return ![audioTrack isEnabled];
}


#pragma - private method.

- (RTCMediaStream *)createLocalMediaStream {
    RTCMediaStream* localStream = [_factory mediaStreamWithLabel:@"ARDAMS"];
    
    [localStream addAudioTrack:[_factory audioTrackWithID:@"ARDAMSa0"]];
    return localStream;
}


- (RTCICEServer *)defaultSTUNServer {
    NSURL *defaultSTUNServerURL = [NSURL URLWithString:self.iceUrl];
    return [[RTCICEServer alloc] initWithURI:defaultSTUNServerURL
                                    username:@""
                                    password:@""];
}

- (RTCICEServer *)defaultTurnServer {
    NSString *ip = [self.iceUrl componentsSeparatedByString:@":"][1];
    NSString *turnUrl = [NSString stringWithFormat:@"turn:%@", ip];
    NSURL *defaultSTUNServerURL = [NSURL URLWithString:turnUrl];
    return [[RTCICEServer alloc] initWithURI:defaultSTUNServerURL
                                    username:@""
                                    password:@""];
}

- (void) setState:(MultiCallClientState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    [_delegate MultiCallClient:self didChangeState:_state];
}

- (void)disconnect {
    if (_state == kMultiCallClientStateDisconnected) {
        return;
    }
    [_peerConnections enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        MultiCallPeerConnection *pc = obj;
        [pc disconnect];
    }];
    [_peerConnections removeAllObjects];
    [_chanel disconnect];
    _chanel = nil;
    self.state = kMultiCallClientStateDisconnected;
}

- (MultiCallPeerConnection *) createPeerConnectionWithUid:(NSString *)uid
                                               deviceType:(NSString *)type
                                                  invited:(BOOL)invited{
    MultiCallPeerConnection *pc = [[MultiCallPeerConnection alloc] initWithUid:uid deviceType:type peerConnectionFactory:_factory iceServers:_iceServers chanel:_chanel localStream:self.localStream invited:invited selfUid:_uid];
    pc.delegate = self;
    return pc;
}

- (void)processOfferMessage:(WebRtcSessionDescriptionMessage *)msg {
    NSString *uid = msg.from;
    NSString *deviceType = msg.fromRes;
    NSParameterAssert(uid);
    NSParameterAssert(deviceType);
    MultiCallPeerConnection *pc = [self createPeerConnectionWithUid:uid deviceType:deviceType invited:YES];
    [_peerConnections setObject:pc forKey:[self genPeerConnectionKeyByUid:uid deviceType:deviceType]];
    [pc processSignalMessage:msg];
    [_delegate MultiCallClient:self didJoinedWithUid:msg.from deivce:msg.fromRes];
}

- (void)processAnswerMessage:(WebRtcSessionDescriptionMessage *)msg {
    MultiCallPeerConnection *pc = [_peerConnections objectForKey:[self genPeerConnectionKeyByUid:msg.from deviceType:msg.fromRes]];
    [pc processSignalMessage:msg];
}

- (void)processJoinMessage:(WebRtcJoinRoomMessage *)msg {
    NSString *uid = msg.from;
    NSString *deviceType = msg.fromRes;
    NSParameterAssert(uid);
    NSParameterAssert(deviceType);
    MultiCallPeerConnection *pc = [self createPeerConnectionWithUid:uid deviceType:deviceType invited:NO];
    [_peerConnections setObject:pc forKey:[self genPeerConnectionKeyByUid:uid deviceType:deviceType]];
    [pc processSignalMessage:msg];
    [_delegate MultiCallClient:self didJoinedWithUid:msg.from deivce:msg.fromRes];
}

- (void)processLeaveMessage:(WebRtcLeaveRoomMessage *)msg {
    MultiCallPeerConnection *pc = [_peerConnections objectForKey:[self genPeerConnectionKeyByUid:msg.from deviceType:msg.fromRes]];
    [pc disconnect];
    [_peerConnections removeObjectForKey:[self genPeerConnectionKeyByUid:msg.from deviceType:msg.fromRes]];
    [_delegate MultiCallClient:self didLeaveWithUid:msg.uid deivce:msg.deviceType];
}

- (NSString *)genPeerConnectionKeyByUid:(NSString *)uid deviceType:(NSString *)type {
    return [NSString stringWithFormat:@"%@@%@", uid, type];
}



#pragma <WebRtcWebSocketChannelDelegate>
- (void)channel:(WebRtcWebSocketChannel *)channel
 didChangeState:(WebRtcWebSocketChannelState)state {
    switch (state) {
        case kWebRtcWebSocketChannelStateOpen:
            break;
        case kWebRtcWebSocketChannelStateClosed:
        case kWebRtcWebSocketChannelStateError:
            [self disconnect];
        default:
            break;
    }
}

- (void)channel:(WebRtcWebSocketChannel *)channel
didReceiveMessage:(WebRtcSignalingMessage *)message {
    if ([message isKindOfClass:[WebRtcSeqMessage class]]) {
        WebRtcSeqMessage *seqMsg = (WebRtcSeqMessage *)message;
        _seq = [seqMsg.seq copy];
        return;
    }
    
    if ([message isKindOfClass:[WebRtcSessionDescriptionMessage class]]) {
        WebRtcSessionDescriptionMessage * sdpMsg = (WebRtcSessionDescriptionMessage *)message;
        if ([sdpMsg.sessionDescription.type isEqual:@"offer"]) {
            [self processOfferMessage:sdpMsg];
        } else {
            [self processAnswerMessage:sdpMsg];
        }
        return;
    }
    
    if ([message isKindOfClass:[WebRtcCandidateMessage class]]) {
        WebRtcCandidateMessage *candidateMsg = (WebRtcCandidateMessage *)message;
        MultiCallPeerConnection *pc = [_peerConnections objectForKey:[self genPeerConnectionKeyByUid:candidateMsg.from deviceType:candidateMsg.fromRes]];
        [pc processSignalMessage:candidateMsg];
        return;
    }
    
    
    if ([message isKindOfClass:[WebRtcJoinRoomMessage class]]) {
         WebRtcJoinRoomMessage *joinMsg = (WebRtcJoinRoomMessage *)message;
        [self processJoinMessage:joinMsg];
        return;
    }
    
    if ([message isKindOfClass:[WebRtcLeaveRoomMessage class]]) {
        WebRtcLeaveRoomMessage *leaveMsg = (WebRtcLeaveRoomMessage *)message;
        [self processLeaveMessage:leaveMsg];
        return;
    }
    DDLogWarn(@"WARN: receive a unkown message. @multiCall.");
}

#pragma mark - MultiCallPeerConnectionDelegate
- (void)MultiCallPeerConnection:(MultiCallPeerConnection *)connection
                       didError:(NSError *) error {
    [_delegate MultiCallClient:self didLeaveWithUid:connection.uid deivce:connection.deviceType];
}
- (void)MultiCallPeerConnection:(MultiCallPeerConnection *)connection didReceiveAudioTrack:(RTCAudioTrack *)audioTrack {
    [_delegate MultiCallClient:self recviveRemoteAudioFromUid:connection.uid];
}
@end
