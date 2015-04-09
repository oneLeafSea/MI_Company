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

//static NSString *kWebrtcDefaultSTUNServerUrl =  @"stun:10.22.1.159";


static NSString *kWebRtcClientErrorDomain = @"WebRtcClient";
static NSInteger kWebRtcClientErrorCreateSDP = -1;
static NSInteger kWebRtcClientErrorSetSDP = -2;

@interface WebRtcClient()<WebRtcWebSocketChannelDelegate,
RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate> {
    WebRtcWebSocketChannel *m_channel;
    BOOL                    m_front;
    NSString               *m_seq;
}
@property(nonatomic, strong) RTCPeerConnection *peerConnection;
@property(nonatomic, strong) RTCPeerConnectionFactory *factory;
@property(nonatomic, strong) NSMutableArray *iceServers;
@property(nonatomic, strong) NSMutableArray *messageQueue;


@end

@implementation WebRtcClient

- (instancetype)initWithDelegate:(id<WebRtcClientDelegate>)delegate
                      roomServer:(NSURL *)url
                          iceUrl:(NSString *)iceUrl
                           token:(NSString *)token
                             key:(NSString *)key
                              iv:(NSString *)iv
                             uid:(NSString *)uid
                         invited:(BOOL)invited{
    if (self = [super init]) {
        _serverHost = url;
        _iceUrl = iceUrl;
        _uid = uid;
        _delegate = delegate;
        _factory = [[RTCPeerConnectionFactory alloc] init];
        _iceServers = [NSMutableArray arrayWithObject:[self defaultSTUNServer]];
        _messageQueue = [[NSMutableArray alloc] init];
        _invited = invited;
        _token = token;
        _iv = iv;
        _key = key;
        m_front = YES;
    }
    return self;
}

//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
//}

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

- (void)mute {
    RTCMediaStream *localStream = _peerConnection.localStreams[0];
    RTCAudioTrack *audioTrack = localStream.audioTracks[0];
    [audioTrack setEnabled:![audioTrack isEnabled]];
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


- (void)createRoomWithId:(NSString *)roomId Completion:(void(^)(BOOL finished))completion {
    m_channel = [[WebRtcWebSocketChannel alloc] initWithUrl:self.serverHost delegate:self];
    [m_channel connectWithCompletion:^(BOOL ok) {
        if (ok) {
            WebRtcCreateRoomMessage *m = [[WebRtcCreateRoomMessage alloc] initWithFrom:_uid
                                                                                    to:@""
                                                                                 msgId:[NSUUID uuid]
                                                                                 topic:@"create"
                                                                            content:nil];
            m.seq = [NSString stringWithFormat:@"%@%@", m_seq, [NSUUID uuid]];
            m.seq = [Encrypt encodeWithKey:self.key iv:self.iv data:[m.seq dataUsingEncoding:NSUTF8StringEncoding] error:nil];
            m.token = self.token;
            _roomId = roomId;
            [m setRoomId:_roomId uid:_uid];
            [m_channel sendMessage:m ack:^(WebRtcAckMessage *ackMsg) {
                BOOL ok = [ackMsg.ack isEqualToString:kWebRtcAckMessageOK];
                if (ok) {
                    self.state = kWebRtcClientStateConnected;
                    RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
                    _peerConnection = [_factory peerConnectionWithICEServers:_iceServers
                                                                 constraints:constraints
                                                                    delegate:self];
                    RTCMediaStream *localStream = [self createLocalMediaStream];
                    [_peerConnection addStream:localStream];
                }
                completion(ok);
            }];
        } else {
            completion(NO);
        }
    }];
}

- (void)joinRoomId:(NSString *)rid completion:(void(^)(BOOL finished))completion {
    m_channel = [[WebRtcWebSocketChannel alloc] initWithUrl:self.serverHost delegate:self];
    [m_channel connectWithCompletion:^(BOOL ok) {
        if (ok) {
            self.state = kWebRtcClientStateConnected;
            WebRtcJoinRoomMessage *m = [[WebRtcJoinRoomMessage alloc] initWithFrom:_uid
                                                                                to:@""
                                                                             msgId:[NSUUID uuid]
                                                                             topic:@"join"
                                                                           content:nil];
            
            m.seq = [NSString stringWithFormat:@"%@%@", m_seq, [NSUUID uuid]];
            m.seq = [Encrypt encodeWithKey:self.key iv:self.iv data:[m.seq dataUsingEncoding:NSUTF8StringEncoding] error:nil];
            m.token = self.token;
            [m setRid:rid];
            [m_channel sendMessage:m ack:^(WebRtcAckMessage *ackMsg) {
                completion([ackMsg.ack isEqualToString:kWebRtcAckMessageOK]);
            }];
        } else {
            completion(NO);
        }
    }];
    
}

- (void)sendOffer {
    [_peerConnection createOfferWithDelegate:self constraints:[self defaultOfferConstraints]];
}


- (RTCMediaStream *)createLocalMediaStream {
    RTCMediaStream* localStream = [_factory mediaStreamWithLabel:@"ARDAMS"];
    
    RTCVideoTrack *localVideoTrack = [self createLocalVideoTrack];
    if (localVideoTrack) {
        [localStream addVideoTrack:localVideoTrack];
        [_delegate WebRtcClient:self didReceiveLocalVideoTrack:localVideoTrack];
    }
    
    [localStream addAudioTrack:[_factory audioTrackWithID:@"ARDAMSa0"]];
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
    
    NSString *cameraID = nil;
    for (AVCaptureDevice *captureDevice in
         [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (captureDevice.position == AVCaptureDevicePositionFront) {
            cameraID = [captureDevice localizedName];
            break;
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

- (void)disconnect {
    if (_state == kWebRtcClientStateDisconnected) {
        return;
    }
//    WebRtcLeaveRoomMessage *m = [[WebRtcLeaveRoomMessage alloc] initWithFrom:_uid to:_talkingUid msgId:[NSUUID uuid] topic:@"leave" content:nil];
//    m.uid = _uid;
//    [m_channel sendData:m.JSONData];
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
    RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
    _peerConnection = [_factory peerConnectionWithICEServers:_iceServers
                                                 constraints:constraints
                                                    delegate:self];
    RTCMediaStream *localStream = [self createLocalMediaStream];
    [_peerConnection addStream:localStream];
    _talkingUid = sdpMsg.from;
    [_messageQueue addObject:sdpMsg];
    RTCSessionDescription *description = sdpMsg.sessionDescription;
    [_peerConnection setRemoteDescriptionWithDelegate:self
                                   sessionDescription:description];
     DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)processJoinMesssage:(WebRtcJoinRoomMessage *)joinMsg {
    _talkingUid = joinMsg.from;
    [_messageQueue addObject:joinMsg];
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
        [_peerConnection addICECandidate:candidateMsg.candidate];
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
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
   iceGatheringChanged:(RTCICEGatheringState)newState {
    DDLogInfo(@"ICE gathering state changed: %d", newState);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       gotICECandidate:(RTCICECandidate *)candidate {
    dispatch_async(dispatch_get_main_queue(), ^{
        WebRtcCandidateMessage *message = [[WebRtcCandidateMessage alloc] initWithFrom:_uid to:_talkingUid msgId:[NSUUID uuid] topic:@"message" content:nil];
        message.candidate = candidate;
        [m_channel sendData:message.JSONData];
    });
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel {
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
        [_peerConnection setLocalDescriptionWithDelegate:self
                                      sessionDescription:sdp];
        for (WebRtcSignalingMessage *msg in _messageQueue) {
            if ([msg isKindOfClass:[WebRtcJoinRoomMessage class]]) {
                WebRtcSessionDescriptionMessage *message =
                [[WebRtcSessionDescriptionMessage alloc] initWithFrom:_uid to:msg.from msgId:[NSUUID uuid] topic:@"message" content:nil];
                message.sessionDescription = sdp;
                [m_channel sendData:[message JSONData]];
            }
            
            if ([msg isKindOfClass:[WebRtcSessionDescriptionMessage class]]) {
                WebRtcSessionDescriptionMessage *offerMsg = (WebRtcSessionDescriptionMessage *)msg;
                if ([offerMsg.sessionDescription.type isEqualToString:@"offer"]) {
                    WebRtcSessionDescriptionMessage *answerMsg = [[WebRtcSessionDescriptionMessage alloc] initWithFrom:_uid to:offerMsg.from msgId:[NSUUID uuid] topic:@"message" content:nil];
                    answerMsg.sessionDescription = sdp;
                    [m_channel sendData:[answerMsg JSONData]];
                }
                
            }
        }
        [_messageQueue removeAllObjects];
    });
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
        DDLogInfo(@"设置romote sdp 成功。");
        if (self.invited && !self.peerConnection.localDescription) {
            RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
            [_peerConnection createAnswerWithDelegate:self
                                          constraints:constraints];
        }
    });
}

#pragma mark - default

- (RTCMediaConstraints *)defaultMediaStreamConstraints {
    NSArray *mandatoryConstraints = @[[[RTCPair alloc] initWithKey:@"maxWidth" value:@"640"]];
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:mandatoryConstraints
     optionalConstraints:nil];
    return constraints;
}

- (RTCICEServer *)defaultSTUNServer {
    NSURL *defaultSTUNServerURL = [NSURL URLWithString:self.iceUrl];
    return [[RTCICEServer alloc] initWithURI:defaultSTUNServerURL
                                    username:@""
                                    password:@""];
}

- (RTCMediaConstraints *)defaultPeerConnectionConstraints {
    NSArray *optionalConstraints = @[
//                                     [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]
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
