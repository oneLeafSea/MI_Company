//
//  MultiCallPeerConnection.m
//  IM
//
//  Created by 郭志伟 on 15/5/4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "MultiCallPeerConnection.h"
#import "RTCPair.h"
#import "RTCMediaConstraints.h"
#import "LogLevel.h"
#import "NSUUID+StringUUID.h"
#import "RTCMediaStream.h"
#import "RTCVideoTrack.h"
#import "RTCAudioTrack.h"
#import "RTCSessionDescriptionDelegate.h"


static NSString *kMultiCallPeerConnectionErrorDomain = @"MultiCallPeerConnection";
static NSInteger kMultiCallPeerConnectionErrorCreateSDP = -1;
static NSInteger kMultiCallPeerConnectionErrorSetSDP = -2;
static NSString *kDeviceType = @"iphone";

@interface MultiCallPeerConnection() <RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate> {
    RTCPeerConnection *_peerConnection;
    __weak RTCPeerConnectionFactory *_factory;
    __weak NSArray *_iceArray;
    __weak WebRtcWebSocketChannel *_chanel;
    BOOL   _iceStateFinished;
    BOOL   _iceGatherFinished;
    BOOL   _ready;
}
@property(nonatomic, strong) NSMutableArray *candidateQueue;
@end

@implementation MultiCallPeerConnection

- (instancetype)initWithUid:(NSString *)uid
                 deviceType:(NSString *)deviceType
      peerConnectionFactory:(RTCPeerConnectionFactory *)factory
                 iceServers:(NSArray *)iceArray
                     chanel:(WebRtcWebSocketChannel *)chanel
                localStream:(RTCMediaStream *)loacalStream
                    invited:(BOOL)invited
                    selfUid:(NSString *)selfUid{
    NSParameterAssert(uid);
    NSParameterAssert(deviceType);
    if (self = [super init]) {
        _uid = [uid copy];
        _deviceType = [deviceType copy];
        _factory = factory;
        _iceArray = iceArray;
        _peerConnection = [_factory peerConnectionWithICEServers:_iceArray constraints:[self defaultPeerConnectionConstraints] delegate:self];
        [_peerConnection addStream:loacalStream];
        _invited = invited;
        _candidateQueue = [[NSMutableArray alloc] init];
        _chanel = chanel;
        _selfUid = [selfUid copy];
        _ready = NO;
    }
    return self;
}

- (void)processSignalMessage:(WebRtcSignalingMessage *)message {
    if ([message isKindOfClass:[WebRtcSessionDescriptionMessage class]]) {
        WebRtcSessionDescriptionMessage * sdpMsg = (WebRtcSessionDescriptionMessage *)message;
        if ([sdpMsg.sessionDescription.type isEqual:@"offer"]) {
            [self processOfferMessage:sdpMsg];
        } else {
            [self processAnswerMessage:sdpMsg];
        }
        return;
    }
    
    if ([message isKindOfClass:[WebRtcJoinRoomMessage class]]) {
        WebRtcJoinRoomMessage *joinMsg = (WebRtcJoinRoomMessage *)message;
        [self processJoinMessage:joinMsg];
        return;
    }
    
    if ([message isKindOfClass:[WebRtcCandidateMessage class]]) {
        WebRtcCandidateMessage *candidateMsg = (WebRtcCandidateMessage *)message;
        [_candidateQueue addObject:candidateMsg.candidate];
        [self drainMessageQueueIfReady];
        DDLogInfo(@"INFO: add ice candidate.");
        return;
    }
}

- (void)disconnect {
    [_peerConnection close];
}

#pragma mark -private method

- (void)processOfferMessage:(WebRtcSessionDescriptionMessage *)sdpMsg {
    DDLogInfo(@"收到offer。");
    RTCSessionDescription *description = sdpMsg.sessionDescription;
    [_peerConnection setRemoteDescriptionWithDelegate:self
                                   sessionDescription:description];
}

- (void)processAnswerMessage:(WebRtcSessionDescriptionMessage *)sdpMsg {
    RTCSessionDescription *description = sdpMsg.sessionDescription;
    [_peerConnection setRemoteDescriptionWithDelegate:self
                                   sessionDescription:description];
}

- (void)processJoinMessage:(WebRtcJoinRoomMessage *)msg {
    [self sendOffer];
}

- (void)processCandidateMessage:(WebRtcCandidateMessage *)msg {
    [_candidateQueue addObject:msg];
    [self drainMessageQueueIfReady];
}

- (void)drainMessageQueueIfReady {
    if (_ready) {
        for (RTCICECandidate *c in _candidateQueue) {
            [_peerConnection addICECandidate:c];
        }
        [_candidateQueue removeAllObjects];
    }
}

- (void)sendOffer {
    [_peerConnection createOfferWithDelegate:self constraints:[self defaultOfferConstraints]];
}

- (RTCMediaConstraints *)defaultPeerConnectionConstraints {
    NSArray *optionalConstraints = @[
                                     [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"false"]
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
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"false"]
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

#pragma mark - <RTCPeerConnectionDelegate>
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
        if (stream.audioTracks.count) {
            RTCAudioTrack *audioTrack = stream.audioTracks[0];
            [_delegate MultiCallPeerConnection:self didReceiveAudioTrack:audioTrack];
        }
    });
}

// Triggered when a remote peer close a stream.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
         removedStream:(RTCMediaStream *)stream {
    DDLogInfo(@"Stream was removed.");
}

// Triggered when renegotiation is needed, for example the ICE has restarted.
- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection {
    DDLogInfo(@"WARNING: Renegotiation needed but unimplemented.");
}

// Called any time the ICEConnectionState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
  iceConnectionChanged:(RTCICEConnectionState)newState {
    DDLogInfo(@"ICE state changed: %d", newState);
    if (newState == RTCICEConnectionConnected) {
        _iceStateFinished = YES;
    }
}

// Called any time the ICEGatheringState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
   iceGatheringChanged:(RTCICEGatheringState)newState {
    if (newState == RTCICEGatheringComplete) {
        _iceGatherFinished = YES;
    }
    DDLogInfo(@"ICE gathering state changed: %d", newState);
}

// New Ice candidate have been found.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
       gotICECandidate:(RTCICECandidate *)candidate {
    dispatch_async(dispatch_get_main_queue(), ^{
        WebRtcCandidateMessage *message = [[WebRtcCandidateMessage alloc] initWithFrom:_selfUid fromRes:kDeviceType to:_uid toRes:_deviceType msgId:[NSUUID uuid] topic:@"message" content:nil];
        message.candidate = candidate;
        [_chanel sendData:message.JSONData];
    });
}

// New data channel has been opened.
- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}


#pragma mark -<RTCSessionDescriptionDelegate>
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
            [[NSError alloc] initWithDomain:kMultiCallPeerConnectionErrorDomain
                                       code:kMultiCallPeerConnectionErrorCreateSDP
                                   userInfo:userInfo];
            [_delegate MultiCallPeerConnection:self didError:sdpError];
            return;
        }
        [_peerConnection setLocalDescriptionWithDelegate:self
                                      sessionDescription:sdp];
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
            [[NSError alloc] initWithDomain:kMultiCallPeerConnectionErrorDomain
                                       code:kMultiCallPeerConnectionErrorSetSDP
                                   userInfo:userInfo];
            [_delegate MultiCallPeerConnection:self didError:sdpError];
            return;
        }
        DDLogInfo(@"设置 sdp 成功。");
        if (self.invited) {
            if (self.peerConnection.localDescription) {
                WebRtcSessionDescriptionMessage *answerMsg = [[WebRtcSessionDescriptionMessage alloc] initWithFrom:_selfUid fromRes:kDeviceType to:_uid toRes:_deviceType msgId:[NSUUID uuid] topic:@"message" content:nil];
                answerMsg.sessionDescription = _peerConnection.localDescription;
                [_chanel sendData:[answerMsg JSONData]];
                _ready = YES;
                [self drainMessageQueueIfReady];
            } else {
                [self.peerConnection createAnswerWithDelegate:self constraints:[self defaultAnswerConstraints]];
            }
        } else {
            if (self.peerConnection.remoteDescription) {
                _ready = YES;
                [self drainMessageQueueIfReady];
            } else {
                WebRtcSessionDescriptionMessage *offerMsg = [[WebRtcSessionDescriptionMessage alloc] initWithFrom:_selfUid fromRes:kDeviceType to:_uid toRes:_deviceType msgId:[NSUUID uuid] topic:@"message" content:nil];
                offerMsg.sessionDescription = _peerConnection.localDescription;
                NSLog(@"type: %@", offerMsg.sessionDescription.type);
                [_chanel sendData:[offerMsg JSONData]];
            }
        }
    });
}


@end
