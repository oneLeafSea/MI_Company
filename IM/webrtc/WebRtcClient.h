//
//  WebRtcClient.h
//  IM
//
//  Created by 郭志伟 on 15-3-25.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#define _DEBUG

#import "RTCVideoTrack.h"
#import "session.h"

@protocol WebRtcClientDelegate;

typedef NS_ENUM(NSInteger, WebRtcClientState) {
    // Disconnected from servers.
    kWebRtcClientStateDisconnected,
    // Connecting to servers.
    kWebRtcClientStateConnecting,
    // Connected to servers.
    kWebRtcClientStateConnected,
    
    kWebRtcClientStateLeave,
    kWebRtcClientStateTimeout
};


@interface WebRtcClient : NSObject

@property(nonatomic, readonly) NSString *uid;
@property(nonatomic, readonly) NSString *roomId;
@property(nonatomic, readonly) NSURL    *serverHost;
@property(nonatomic, readonly) WebRtcClientState state;
@property(nonatomic, weak) id<WebRtcClientDelegate> delegate;
@property(nonatomic, readonly) NSString *talkingUid;

- (instancetype)initWithDelegate:(id<WebRtcClientDelegate>)delegate
                      roomServer:(NSURL *)url
                         stunUrl:(NSString *)stunUrl
                         turnUrl:(NSString *)turnUrl
                           token:(NSString *)token
                             key:(NSString *)key
                              iv:(NSString *)iv
                             uid:(NSString *)uid
                         invited:(BOOL)invited;

- (void)createRoomWithId:(NSString *)roomId
              Completion:(void(^)(BOOL finished))completion;

- (void)joinRoomId:(NSString *)rid completion:(void(^)(BOOL finished))completion;

- (void)disconnect;

- (void)swichCamera;

- (void)mute;

- (BOOL)isMute;

- (void)sendVideoMsgWithEnable:(BOOL)enable;

- (BOOL)isConnected;

@property(nonatomic, readonly) BOOL invited;
@property(nonatomic, readonly) NSString *stunUrl;
@property(nonatomic, readonly) NSString *turnUrl;
@property(nonatomic, readonly) NSString *token;
@property(nonatomic, readonly) NSString *key;
@property(nonatomic, readonly) NSString *iv;

@end


@protocol WebRtcClientDelegate <NSObject>

- (void)WebRtcClient:(WebRtcClient *)client
   didChangeState:(WebRtcClientState)state;

- (void)WebRtcClient:(WebRtcClient *)client
didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;

- (void)WebRtcClient:(WebRtcClient *)client
didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;

- (void)WebRtcClient:(WebRtcClient *)client
         didError:(NSError *)error;

- (void)WebRtcClient:(WebRtcClient *)client videoEnabled:(BOOL)enable;

@end