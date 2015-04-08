//
//  WebRtcWebSocketChannel.h
//  IM
//
//  Created by 郭志伟 on 15-3-25.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRtcSignalingMessage.h"
#import "WebRtcAckMessage.h"

typedef NS_ENUM(NSInteger, WebRtcWebSocketChannelState) {
    // State when disconnected.
    kWebRtcWebSocketChannelStateClosed,
    // State when connection is established but not ready for use.
    kWebRtcWebSocketChannelStateOpen,
    // State when connection encounters a fatal error.
    kWebRtcWebSocketChannelStateError
};

@protocol WebRtcWebSocketChannelDelegate;

@interface WebRtcWebSocketChannel : NSObject

@property(nonatomic, readonly) WebRtcWebSocketChannelState state;
- (instancetype)initWithUrl:(NSURL *)url
                   delegate:(id<WebRtcWebSocketChannelDelegate>)delegate;

- (void)connectWithCompletion:(void(^)(BOOL ok))completion;
- (void)sendData:(NSData *)data;
- (void)sendMessage:(WebRtcSignalingMessage *)msg ack:(void(^)(WebRtcAckMessage *ackMsg)) ack;
- (void)disconnect;

@property(weak, nonatomic) id<WebRtcWebSocketChannelDelegate> delegate;

@end


@protocol WebRtcWebSocketChannelDelegate <NSObject>

- (void)channel:(WebRtcWebSocketChannel *)channel
 didChangeState:(WebRtcWebSocketChannelState)state;

- (void)channel:(WebRtcWebSocketChannel *)channel
didReceiveMessage:(WebRtcSignalingMessage *)message;

@end