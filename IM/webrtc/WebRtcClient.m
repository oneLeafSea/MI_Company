//
//  WebRtcClient.m
//  IM
//
//  Created by 郭志伟 on 15-3-25.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "WebRtcClient.h"

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "NSUUID+StringUUID.h"
#import "WebRtcWebSocketChannel.h"
#import "WebRtcSignalingMessage.h"

#import "RTCMediaConstraints.h"
#import "RTCMediaStream.h"
#import "RTCPair.h"
#import "RTCPeerConnection.h"
#import "RTCPeerConnectionDelegate.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCSessionDescription+JSON.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCVideoCapturer.h"
#import "RTCVideoTrack.h"
#import "RTCAudioTrack.h"
#import "RTCICEServer+JSON.h"
#import "LogLevel.h"
#import "Encrypt.h"


static NSString *kWebRtcClientErrorDomain = @"WebRtcClient";
static NSInteger kWebRtcClientErrorCreateSDP = -1;
static NSInteger kWebRtcClientErrorSetSDP = -2;
static NSUInteger kWebrtcTimeout = 60 * 60;
static NSString *kDeviceType = @"iphone";

@interface WebRtcClient()<WebRtcWebSocketChannelDelegate,
RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate> {
    WebRtcWebSocketChannel *m_channel;
    BOOL                    m_front;
    NSString               *m_seq;
    NSTimer                *m_timer;
    BOOL                    m_iceStateFinished;
    BOOL                    m_iceGatherFinished;
    NSString               *m_toRes;
     BOOL                   _ready;
}
@property(nonatomic, strong) RTCPeerConnection *peerConnection;
@property(nonatomic, strong) RTCPeerConnectionFactory *factory;
@property(nonatomic, strong) NSMutableArray *iceServers;
@property(nonatomic, strong) NSMutableArray *candidateQueue;


@end

@implementation WebRtcClient

- (instancetype)initWithDelegate:(id<WebRtcClientDelegate>)delegate
                      roomServer:(NSURL *)url
                         stunUrl:(NSString *)stunUrl
                         turnUrl:(NSString *)turnUrl
                           token:(NSString *)token
                             key:(NSString *)key
                              iv:(NSString *)iv
                             uid:(NSString *)uid
                         invited:(BOOL)invited{
    if (self = [super init]) {
        _serverHost = url;
        _stunUrl = [stunUrl copy];
        _turnUrl = [turnUrl copy];
        _uid = uid;
        _delegate = delegate;
        _factory = [[RTCPeerConnectionFactory alloc] init];
//        _iceServers = [NSMutableArray arrayWithObjects:[self defaultSTUNServer], [self defaultTurnServer], nil];
        
        _iceServers = [NSMutableArray arrayWithArray:[self stunServers]];
        [_iceServers addObjectsFromArray:[self turnUrlServers]];
        _candidateQueue = [[NSMutableArray alloc] init];
        _invited = invited;
        _token = token;
        _iv = iv;
        _key = key;
        m_front = YES;
        _ready = NO;
    }
    return self;
}


- (void)swichCamera {
    if (m_front) {
        RTCMediaStream *localStream = _peerConnection.localStreams[0];
        [localStream removeVideoTrack:localStream.videoTracks[0]];
        
        RTCVideoTrack *localVideoTrack = [self createLocalVideoTrackWithFront:NO];
        if (localVideoTrack) {
            [localStream addVideoTrack:localVideoTrack];
            [_delegate WebRtcClient:self didReceiveLocalVideoTrack:localVideoTrack];
        }
        [_peerConnection removeStream:localStream];
        [_peerConnection addStream:localStream];
        m_front = NO;
    } else {
        RTCMediaStream *localStream = _peerConnection.localStreams[0];
        [localStream removeVideoTrack:localStream.videoTracks[0]];
        
        RTCVideoTrack *localVideoTrack = [self createLocalVideoTrackWithFront:YES];
        if (localVideoTrack) {
            [localStream addVideoTrack:localVideoTrack];
            [_delegate WebRtcClient:self didReceiveLocalVideoTrack:localVideoTrack];
        }
        [_peerConnection removeStream:localStream];
        [_peerConnection addStream:localStream];
        m_front = YES;
    }
}

- (BOOL)isConnected {
    return m_iceGatherFinished && m_iceStateFinished;
}


- (void)mute {
    RTCMediaStream *localStream = _peerConnection.localStreams[0];
    RTCAudioTrack *audioTrack = localStream.audioTracks[0];
    [audioTrack setEnabled:![audioTrack isEnabled]];
}

- (BOOL)isMute {
    RTCMediaStream *localStream = _peerConnection.localStreams[0];
    RTCAudioTrack *audioTrack = localStream.audioTracks[0];
    return ![audioTrack isEnabled];
}

- (void)sendVideoMsgWithEnable:(BOOL)enable {
    WebRtcVideoMessage *msg = [[WebRtcVideoMessage alloc] initWithFrom:self.uid fromRes:kDeviceType to:self.talkingUid toRes:m_toRes msgId:[NSUUID uuid] topic:@"message" content:nil];
    msg.enable = enable;
    [m_channel sendData:msg.JSONData];
}

- (RTCVideoTrack *)createLocalVideoTrackWithFront:(BOOL) front {
    RTCVideoTrack *localVideoTrack = nil;
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_IPHONE
    
    NSString *cameraID = nil;
    for (AVCaptureDevice *captureDevice in
         [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (front) {
            if (captureDevice.position == AVCaptureDevicePositionFront) {
                cameraID = [captureDevice localizedName];
                break;
            }
        } else {
            if (captureDevice.position == AVCaptureDevicePositionBack) {
                cameraID = [captureDevice localizedName];
                break;
            }
        }
        
    }
    NSAssert(cameraID, @"Unable to get the front camera id");
    
    RTCVideoCapturer *capturer = [RTCVideoCapturer capturerWithDeviceName:cameraID];
    RTCMediaConstraints *mediaConstraints = [self defaultMediaStreamConstraints];
    RTCVideoSource *videoSource = [_factory videoSourceWithCapturer:capturer constraints:mediaConstraints];
    localVideoTrack = [_factory videoTrackWithID:@"ARDAMSv0" source:videoSource];
#endif
    return localVideoTrack;
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(orientation) || UIDeviceOrientationIsPortrait(orientation)) {
        //Remove current video track
        RTCMediaStream *localStream = _peerConnection.localStreams[0];
        [localStream removeVideoTrack:localStream.videoTracks[0]];
        
        RTCVideoTrack *localVideoTrack = [self createLocalVideoTrack];
        if (localVideoTrack) {
            [localStream addVideoTrack:localVideoTrack];
            [_delegate WebRtcClient:self didReceiveLocalVideoTrack:localVideoTrack];
        }
        [_peerConnection removeStream:localStream];
        [_peerConnection addStream:localStream];
    }
}


- (void)createRoomWithId:(NSString *)roomId
              Completion:(void(^)(BOOL finished))completion {
    [self startTimer];
    m_channel = [[WebRtcWebSocketChannel alloc] initWithUrl:self.serverHost delegate:self];
    [m_channel connectWithCompletion:^(BOOL ok) {
        if (ok) {
            WebRtcCreateRoomMessage *m = [[WebRtcCreateRoomMessage alloc] initWithFrom:_uid
                                                                               fromRes:@"iphone"
                                                                                    to:@""
                                                                                 toRes:@""
                                                                                 msgId:[NSUUID uuid]
                                                                                 topic:@"create"
                                                                            content:nil];
            m.seq = [NSString stringWithFormat:@"%@%@", m_seq, [NSUUID uuid]];
            m.seq = [Encrypt encodeWithKey:self.key iv:self.iv data:[m.seq dataUsingEncoding:NSUTF8StringEncoding] error:nil];
            m.token = self.token;
            _roomId = roomId;
            [m setRoomId:_roomId uid:_uid];
            [m_channel sendData:m.JSONData];
            self.state = kWebRtcClientStateConnected;
        }
        completion(ok);
    }];
}

- (void)startTimer {
    m_timer = [NSTimer scheduledTimerWithTimeInterval:kWebrtcTimeout target:self selector:@selector(timeout) userInfo:nil repeats:NO];
}

- (void)timeout {
    if (m_iceGatherFinished && m_iceStateFinished) {
        return;
    }
    [_delegate WebRtcClient:self didChangeState:kWebRtcClientStateTimeout];
}

- (void)createPeerConnection {
    DDLogCInfo(@"1");
    RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
    DDLogCInfo(@"2");
    _peerConnection = [_factory peerConnectionWithICEServers:_iceServers
                                                 constraints:constraints
                                                    delegate:self];
    DDLogCInfo(@"3");
    RTCMediaStream *localStream = [self createLocalMediaStream];
    DDLogCInfo(@"4");
    [_peerConnection addStream:localStream];
    DDLogCInfo(@"5");
}

- (void)drainMessageQueueIfReady {
    if (_ready) {
        for (RTCICECandidate *c in _candidateQueue) {
            [_peerConnection addICECandidate:c];
        }
        [_candidateQueue removeAllObjects];
    }}

- (void)joinRoomId:(NSString *)rid completion:(void(^)(BOOL finished))completion {
    [self startTimer];
    m_channel = [[WebRtcWebSocketChannel alloc] initWithUrl:self.serverHost delegate:self];
    [m_channel connectWithCompletion:^(BOOL ok) {
        if (ok) {
            self.state = kWebRtcClientStateConnected;
            WebRtcJoinRoomMessage *m = [[WebRtcJoinRoomMessage alloc] initWithFrom:_uid
                                                                           fromRes:kDeviceType
                                                                                to:@""
                                                                             toRes:@""
                                                                             msgId:[NSUUID uuid]
                                                                             topic:@"join"
                                                                           content:nil];
            
            m.seq = [NSString stringWithFormat:@"%@%@", m_seq, [NSUUID uuid]];
            m.seq = [Encrypt encodeWithKey:self.key iv:self.iv data:[m.seq dataUsingEncoding:NSUTF8StringEncoding] error:nil];
            m.token = self.token;
            [m setRid:rid];
            [m_channel sendData:[m JSONData]];
            completion(YES);
        } else {
            completion(NO);
        }
    }];
    
}

- (void)sendOffer {
    [_peerConnection createOfferWithDelegate:self constraints:[self defaultOfferConstraints]];
}


- (RTCMediaStream *)createLocalMediaStream {
    DDLogCInfo(@"11");
    RTCMediaStream* localStream = [_factory mediaStreamWithLabel:@"ARDAMS"];
    DDLogCInfo(@"12");
    RTCVideoTrack *localVideoTrack = [self createLocalVideoTrack];
    DDLogCInfo(@"13");
    if (localVideoTrack) {
        [localStream addVideoTrack:localVideoTrack];
        [_delegate WebRtcClient:self didReceiveLocalVideoTrack:localVideoTrack];
    }
    DDLogCInfo(@"14");
    [localStream addAudioTrack:[_factory audioTrackWithID:@"ARDAMSa0"]];
    DDLogCInfo(@"15");
    return localStream;
}

- (RTCVideoTrack *)createLocalVideoTrack {
    // The iOS simulator doesn't provide any sort of camera capture
    // support or emulation (http://goo.gl/rHAnC1) so don't bother
    // trying to open a local stream.
    // TODO(tkchin): local video capture for OSX. See
    // https://code.google.com/p/webrtc/issues/detail?id=3417.
    
    RTCVideoTrack *localVideoTrack = nil;
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_IPHONE
    DDLogCInfo(@"21");
    NSString *cameraID = nil;
    for (AVCaptureDevice *captureDevice in
         [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (captureDevice.position == AVCaptureDevicePositionFront) {
            cameraID = [captureDevice localizedName];
            break;
        }
    }
    DDLogCInfo(@"22");
    NSAssert(cameraID, @"Unable to get the front camera id");
    DDLogCInfo(@"23");
    RTCVideoCapturer *capturer = [RTCVideoCapturer capturerWithDeviceName:cameraID];
    DDLogCInfo(@"24");
    RTCMediaConstraints *mediaConstraints = [self defaultMediaStreamConstraints];
    RTCVideoSource *videoSource = [_factory videoSourceWithCapturer:capturer constraints:mediaConstraints];
    DDLogCInfo(@"25");
    localVideoTrack = [_factory videoTrackWithID:@"ARDAMSv0" source:videoSource];
    DDLogCInfo(@"26");
    [localVideoTrack setEnabled:NO];
#endif
    return localVideoTrack;
}

- (void)disconnect {
    if (_state == kWebRtcClientStateDisconnected) {
        return;
    }
    [_peerConnection close];
     _peerConnection = nil;
    [m_channel disconnect];
    m_channel = nil;
    self.state = kWebRtcClientStateDisconnected;
}

- (void)processAnswerMessage:(WebRtcSessionDescriptionMessage *)sdpMsg {
    RTCSessionDescription *description = sdpMsg.sessionDescription;
    [_peerConnection setRemoteDescriptionWithDelegate:self
                                   sessionDescription:description];
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)processOfferMessage:(WebRtcSessionDescriptionMessage *)sdpMsg {
    DDLogInfo(@"收到offer。");
    [self createPeerConnection];
    DDLogCInfo(@"createPeerConnection");
    _talkingUid = sdpMsg.from;
    m_toRes = [sdpMsg.fromRes copy];
    RTCSessionDescription *description = sdpMsg.sessionDescription;
    [_peerConnection setRemoteDescriptionWithDelegate:self
                                   sessionDescription:description];
    DDLogCInfo(@"createPeerConnection");
}

- (void)processJoinMesssage:(WebRtcJoinRoomMessage *)joinMsg {
    [self createPeerConnection];
    _talkingUid = joinMsg.from;
    m_toRes = [joinMsg.fromRes copy];
//    [_messageQueue addObject:joinMsg];
    [self sendOffer];
     DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)processLeaveMessage:(WebRtcLeaveRoomMessage *)leaveMsg {
     DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    [_delegate WebRtcClient:self didChangeState:kWebRtcClientStateLeave];
}

- (void)setState:(WebRtcClientState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    [_delegate WebRtcClient:self didChangeState:_state];
}

#pragma mark -WebRtcWebSocketChannelDelegate

- (void)channel:(WebRtcWebSocketChannel *)channel didChangeState:(WebRtcWebSocketChannelState)state {
    switch (state) {
        case kWebRtcWebSocketChannelStateOpen:
            break;
        case kWebRtcWebSocketChannelStateClosed:
        case kWebRtcWebSocketChannelStateError:
            // TODO(tkchin): reconnection scenarios. Right now we just disconnect
            // completely if the websocket connection fails.
            [self disconnect];
            break;
    }
}

- (void)channel:(WebRtcWebSocketChannel *)channel didReceiveMessage:(WebRtcSignalingMessage *)message {
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
        [_candidateQueue addObject:candidateMsg.candidate];
        [self drainMessageQueueIfReady];
        DDLogInfo(@"INFO: add ice candidate.");
        return;
    }
    
    if ([message isKindOfClass:[WebRtcJoinRoomMessage class]]) {
        WebRtcJoinRoomMessage *joinMsg = (WebRtcJoinRoomMessage *)message;
        [self processJoinMesssage:joinMsg];
        return;
    }
    
    if ([message isKindOfClass:[WebRtcLeaveRoomMessage class]]) {
        WebRtcLeaveRoomMessage *leaveMsg = (WebRtcLeaveRoomMessage *)message;
        [self processLeaveMessage:leaveMsg];
        return;
    }
    
    if ([message isKindOfClass:[WebRtcSeqMessage class]]) {
        WebRtcSeqMessage *seqMsg = (WebRtcSeqMessage *)message;
        m_seq = [seqMsg.seq copy];
        return;
    }
    
    if ([message isKindOfClass:[WebRtcVideoMessage class]]) {
        WebRtcVideoMessage *videoMsg = (WebRtcVideoMessage *)message;
        DDLogInfo(@"INFO: receive video msg %d.", videoMsg.enable);
        if ([self.delegate respondsToSelector:@selector(WebRtcClient:videoEnabled:)]) {
            [self.delegate WebRtcClient:self videoEnabled:videoMsg.enable];
        }
        return;
    }
    
    DDLogInfo(@"WARN: receive a unkown message. @webrtc.");
}

#pragma mark - RTCPeerConnectionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection
 signalingStateChanged:(RTCSignalingState)stateChanged {
    DDLogInfo(@"Signaling state changed: %d", stateChanged);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
           addedStream:(RTCMediaStream *)stream {
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogInfo(@"Received %lu video tracks and %lu audio tracks",
              (unsigned long)stream.videoTracks.count,
              (unsigned long)stream.audioTracks.count);
        if (stream.videoTracks.count) {
            RTCVideoTrack *videoTrack = stream.videoTracks[0];
            [_delegate WebRtcClient:self didReceiveRemoteVideoTrack:videoTrack];
        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
         removedStream:(RTCMediaStream *)stream {
    DDLogInfo(@"Stream was removed.");
}

- (void)peerConnectionOnRenegotiationNeeded:
(RTCPeerConnection *)peerConnection {
    DDLogInfo(@"WARNING: Renegotiation needed but unimplemented.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
  iceConnectionChanged:(RTCICEConnectionState)newState {
    DDLogInfo(@"ICE state changed: %d", newState);
    if (newState == RTCICEConnectionConnected) {
        m_iceStateFinished = YES;
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
   iceGatheringChanged:(RTCICEGatheringState)newState {
    if (newState == RTCICEGatheringComplete) {
        m_iceGatherFinished = YES;
    }
    DDLogInfo(@"ICE gathering state changed: %d", newState);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       gotICECandidate:(RTCICECandidate *)candidate {
    dispatch_async(dispatch_get_main_queue(), ^{
        WebRtcCandidateMessage *message = [[WebRtcCandidateMessage alloc] initWithFrom:_uid fromRes:kDeviceType to:_talkingUid toRes:m_toRes msgId:[NSUUID uuid] topic:@"message" content:nil];
        message.candidate = candidate;
        [m_channel sendData:message.JSONData];
    });
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}


#pragma mark - RTCSessionDescriptionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didCreateSessionDescription:(RTCSessionDescription *)sdp
                 error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            DDLogError(@"Failed to create session description. Error: %@", error);
            [self disconnect];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: @"Failed to create session description.",
                                       };
            NSError *sdpError =
            [[NSError alloc] initWithDomain:kWebRtcClientErrorDomain
                                       code:kWebRtcClientErrorCreateSDP
                                   userInfo:userInfo];
            [_delegate WebRtcClient:self didError:sdpError];
            return;
        }
        RTCSessionDescription *preferSdp = [self cnvToVP9Desc:sdp];
        [_peerConnection setLocalDescriptionWithDelegate:self
                                      sessionDescription:preferSdp];
    });
}

- (RTCSessionDescription *)cnvToVP9Desc:(RTCSessionDescription *)sdp {
//    NSLog(@"%@", sdp.description);
    NSArray *array = [sdp.description componentsSeparatedByString:@"\r\n"];
    __block NSInteger mlineIndex = NSNotFound;
    __block NSString *codecRtpmap = nil;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *strLine = obj;
        if ([strLine hasPrefix:@"m=video"]) {
            mlineIndex = idx;
            return;
        }
        if ([strLine hasPrefix:@"a=rtpmap:"] && [strLine containsString:@"VP9"]) {
            codecRtpmap = strLine;
            return;
        }
    }];
    if (mlineIndex == NSNotFound || codecRtpmap == nil) {
        return sdp;
    }
    
    NSLog(@"codecRtpmap:%@", codecRtpmap);
    
    NSArray *rtpArray = [codecRtpmap componentsSeparatedByString:@" "];
    if (rtpArray.count < 2) {
        return sdp;
    }
    NSString *strRtpmap = rtpArray[0];
    NSArray *codeArray = [strRtpmap componentsSeparatedByString:@":"];
    if (codeArray.count < 2) {
        return sdp;
    }
    NSString *strCode = codeArray[1];
    NSString *mStr = [array objectAtIndex:mlineIndex];
    NSArray *mArray = [mStr componentsSeparatedByString:@" "];
    if (mArray.count < 4) {
        return sdp;
    }
    NSMutableArray *resArray = [[NSMutableArray alloc] init];
    [resArray addObject:mArray[0]];
    [resArray addObject:mArray[1]];
    [resArray addObject:mArray[2]];
    [resArray addObject:strCode];
    [mArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < 3) {
            return;
        }
        
        if (![strCode isEqualToString:obj]) {
            [resArray addObject:obj];
        }
    }];
    NSMutableString *newLine = [[NSMutableString alloc] init];
    [resArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == resArray.count - 1) {
            [newLine appendFormat:@"%@", obj];
            return;
        }
        [newLine appendFormat:@"%@ ", obj];
    }];
    
    NSLog(@"newLine:%@", newLine);
    
    NSMutableString *newStrSdp = [NSMutableString stringWithString:sdp.description];
    NSString *strRet = [newStrSdp stringByReplacingOccurrencesOfString:[array objectAtIndex:mlineIndex] withString:newLine];
    RTCSessionDescription *newSdp = [[RTCSessionDescription alloc] initWithType:sdp.type sdp:strRet];
//    NSLog(@"%@", strRet);
    return newSdp;
    
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didSetSessionDescriptionWithError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            DDLogError(@"Failed to set session description. Error: %@", error);
            [self disconnect];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: @"Failed to set session description.",
                                       };
            NSError *sdpError =
            [[NSError alloc] initWithDomain:kWebRtcClientErrorDomain
                                       code:kWebRtcClientErrorSetSDP
                                   userInfo:userInfo];
            [_delegate WebRtcClient:self didError:sdpError];
            return;
        }
        DDLogInfo(@"设置 sdp 成功。");
        if (self.invited) {
            if (self.peerConnection.localDescription) {
                WebRtcSessionDescriptionMessage *answerMsg = [[WebRtcSessionDescriptionMessage alloc] initWithFrom:_uid fromRes:kDeviceType to:_talkingUid toRes:m_toRes msgId:[NSUUID uuid] topic:@"message" content:nil];
                answerMsg.sessionDescription = _peerConnection.localDescription;
                [m_channel sendData:[answerMsg JSONData]];
                _ready = YES;
                [self drainMessageQueueIfReady];
            } else {
                [self.peerConnection createAnswerWithDelegate:self constraints:[self defaultAnswerConstraints]];
            }
        } else {
            if (self.peerConnection.localDescription && !self.peerConnection.remoteDescription) {
                _ready = YES;
                [self drainMessageQueueIfReady];
                WebRtcSessionDescriptionMessage *offerMsg = [[WebRtcSessionDescriptionMessage alloc] initWithFrom:_uid fromRes:kDeviceType to:_talkingUid toRes:m_toRes msgId:[NSUUID uuid] topic:@"message" content:nil];
                offerMsg.sessionDescription = _peerConnection.localDescription;
                NSLog(@"type: %@", offerMsg.sessionDescription.type);
                [m_channel sendData:[offerMsg JSONData]];
            }
        }

    });
}

#pragma mark - default

- (RTCMediaConstraints *)defaultMediaStreamConstraints {
    NSArray *mandatoryConstraints = @[[[RTCPair alloc] initWithKey:@"maxWidth" value:@"640"], [[RTCPair alloc] initWithKey:@"maxHeight" value:@"480"]];
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:mandatoryConstraints
     optionalConstraints:nil];
    return constraints;
}

- (RTCICEServer *)defaultSTUNServer {
    NSURL *defaultSTUNServerURL = [NSURL URLWithString:self.stunUrl];
    return [[RTCICEServer alloc] initWithURI:defaultSTUNServerURL
                                    username:@""
                                    password:@""];
}


- (NSArray *)stunServers {
    __block NSMutableArray *iceServer = [[NSMutableArray alloc] initWithCapacity:5];
    NSArray *stunUrls = [self.stunUrl componentsSeparatedByString:@";"];
    [stunUrls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *url = [NSURL URLWithString:obj];
        RTCICEServer *svr =  [[RTCICEServer alloc] initWithURI:url
                                 username:@""
                                 password:@""];
        [iceServer addObject:svr];
    }];
    return iceServer;
}

- (NSArray *)turnUrlServers {
    __block NSMutableArray *iceServer = [[NSMutableArray alloc] initWithCapacity:5];
    NSArray *stunUrls = [self.turnUrl componentsSeparatedByString:@";"];
    [stunUrls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *url = [NSURL URLWithString:obj];
        RTCICEServer *svr =  [[RTCICEServer alloc] initWithURI:url
                                                      username:@"Rooten"
                                                      password:@"0qhMWkIaFhKrTQzS"];
        [iceServer addObject:svr];
    }];
    return iceServer;
}

- (RTCICEServer *)defaultTurnServer {
    NSURL *defaultTurnServerURL = [NSURL URLWithString:self.turnUrl];
    return [[RTCICEServer alloc] initWithURI:defaultTurnServerURL
                                    username:@"Rooten"
                                    password:@"0qhMWkIaFhKrTQzS"];
}

- (RTCMediaConstraints *)defaultPeerConnectionConstraints {
    NSArray *optionalConstraints = @[
                                     [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]
                                     ];
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:nil
     optionalConstraints:optionalConstraints];
    return constraints;
}

- (RTCMediaConstraints *)defaultOfferConstraints {
    NSArray *mandatoryConstraints = @[
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"],
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"]
                                      ];
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:mandatoryConstraints
     optionalConstraints:nil];
    return constraints;
}

- (RTCMediaConstraints *)defaultAnswerConstraints {
    return [self defaultOfferConstraints];
}


@end
