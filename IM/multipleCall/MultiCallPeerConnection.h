//
//  MultiCallPeerConnection.h
//  IM
//
//  Created by 郭志伟 on 15/5/4.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTCPeerConnection.h"
#import "RTCPeerConnectionFactory.h"
#import "WebRtcSignalingMessage.h"
#import "WebRtcWebSocketChannel.h"

@protocol MultiCallPeerConnectionDelegate;

@interface MultiCallPeerConnection : NSObject

- (instancetype)initWithUid:(NSString *)uid
                 deviceType:(NSString *)deviceType
      peerConnectionFactory:(RTCPeerConnectionFactory *)factory
                 iceServers:(NSArray *)iceArray
                     chanel:(WebRtcWebSocketChannel *)chanel
                localStream:(RTCMediaStream *)loacalStream
                    invited:(BOOL)invited
                    selfUid:(NSString *)selfUid;

- (void)processSignalMessage:(WebRtcSignalingMessage *)msg;

- (void)disconnect;

@property(nonatomic, readonly) NSString *uid;
@property(nonatomic, readonly) NSString *deviceType;
@property(nonatomic, readonly) RTCPeerConnection *peerConnection;
@property(nonatomic, readonly) BOOL invited;
@property(nonatomic, readonly) NSString *selfUid;
@property(weak) id<MultiCallPeerConnectionDelegate> delegate;

@end


@protocol MultiCallPeerConnectionDelegate <NSObject>
@required
- (void)MultiCallPeerConnection:(MultiCallPeerConnection *)connection
                       didError:(NSError *) error;
- (void)MultiCallPeerConnection:(MultiCallPeerConnection *)connection didReceiveAudioTrack:(RTCAudioTrack *)audioTrack;

@end