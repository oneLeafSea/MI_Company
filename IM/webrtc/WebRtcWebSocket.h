//
//  WebRtcSocket.h
//  IM
//
//  Created by 郭志伟 on 15-3-27.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/SecCertificate.h>

typedef enum {
    SR_CONNECTING   = 0,
    SR_OPEN         = 1,
    SR_CLOSING      = 2,
    SR_CLOSED       = 3,
} WebRtcReadyState;

@class WebRtcWebSocket;

extern NSString *const WebRtcSocketErrorDomain;

#pragma mark - WebRtcSocketDelegate

@protocol WebRtcSocketDelegate;

#pragma mark - WebRtcSocket

@interface WebRtcSocket : NSObject <NSStreamDelegate>

@property (nonatomic, assign) id <WebRtcSocketDelegate> delegate;

@property (nonatomic, readonly) WebRtcReadyState readyState;
@property (nonatomic, readonly, retain) NSURL *url;

// This returns the negotiated protocol.
// It will be nil until after the handshake completes.
@property (nonatomic, readonly, copy) NSString *protocol;

// Protocols should be an array of strings that turn into Sec-WebSocket-Protocol.
- (id)initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols;
- (id)initWithURLRequest:(NSURLRequest *)request;

// Some helper constructors.
- (id)initWithURL:(NSURL *)url protocols:(NSArray *)protocols;
- (id)initWithURL:(NSURL *)url;

// Delegate queue will be dispatch_main_queue by default.
// You cannot set both OperationQueue and dispatch_queue.
- (void)setDelegateOperationQueue:(NSOperationQueue*) queue;
- (void)setDelegateDispatchQueue:(dispatch_queue_t) queue;

// By default, it will schedule itself on +[NSRunLoop SR_networkRunLoop] using defaultModes.
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

// WebRtcSockets are intended for one-time-use only.  Open should be called once and only once.
- (void)open;

- (void)close;
- (void)closeWithCode:(NSInteger)code reason:(NSString *)reason;

// Send a UTF8 String or Data.
- (void)send:(id)data;

@end

#pragma mark - WebRtcSocketDelegate

@protocol WebRtcSocketDelegate <NSObject>

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(WebRtcSocket *)webSocket didReceiveMessage:(id)message;

@optional

- (void)webSocketDidOpen:(WebRtcSocket *)webSocket;
- (void)webSocket:(WebRtcSocket *)webSocket didFailWithError:(NSError *)error;
- (void)webSocket:(WebRtcSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

@end

#pragma mark - NSURLRequest (CertificateAdditions)

@interface NSURLRequest (WebrtcCertificateAdditions)

@property (nonatomic, retain, readonly) NSArray *SR_SSLPinnedCertificates;

@end

#pragma mark - NSMutableURLRequest (CertificateAdditions)

@interface NSMutableURLRequest (WebrtcCertificateAdditions)

@property (nonatomic, retain) NSArray *SR_SSLPinnedCertificates;

@end

#pragma mark - NSRunLoop (WebRtcSocket)

@interface NSRunLoop (WebrtcWebRtcSocket)

+ (NSRunLoop *)SR_networkRunLoop;

@end
//#import <Foundation/Foundation.h>
//
//@interface WebRtcSocket : NSObject
//
//@end
